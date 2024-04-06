from typing import Type, List, Optional, Any, Iterable

from langchain_community.utilities.sql_database import SQLDatabase
from langchain_core.documents import Document
from langchain_core.embeddings import Embeddings
from langchain_core.vectorstores import VectorStore, VST

DEFAULT_TABLE_NAME = "embeddings"


class CrateVectorStore(VectorStore):
    def __init__(self,
                 embeddings: Embeddings,
                 db: SQLDatabase,
                 table_name: str = None,
                 drop_if_exists: bool = False):
        self._vector_size = None
        self._embeddings = embeddings
        self._db = db

        self._table_name = DEFAULT_TABLE_NAME
        if table_name:
            self._table_name = table_name

        if drop_if_exists:
            self._db.run(command=f"DROP TABLE IF EXISTS {self._table_name}")

        self._create_table()

    def _get_vector_size(self) -> int:
        if not self._vector_size:
            self._vector_size = len(self._embeddings.embed_query("test"))

        return self._vector_size

    def _create_table(self):
        self._db.run(
            command=f"""
                CREATE TABLE IF NOT EXISTS {self._table_name} (
                    page_content STRING INDEX using fulltext WITH (analyzer = 'english'),
                    embeddings FLOAT_VECTOR({self._get_vector_size()}),
                    metadata OBJECT(DYNAMIC)
                )
            """
        )

    def add_texts(self, texts: Iterable[str], metadatas: Optional[List[dict]] = None, **kwargs: Any) -> List[str]:
        # TODO add bulk insert

        embeddings = self._embeddings.embed_documents(texts=texts)
        for text in texts:
            metadata = metadatas.pop(0) if metadatas else {}
            embedding = embeddings.pop(0)

            cursor = self._db.run(
                command=f"""
                    INSERT INTO {self._table_name}(page_content, embeddings, metadata) 
                    VALUES (:page_content, :embeddings, :metadata)
                """,
                parameters={
                    "page_content": text,
                    "embeddings": embedding,
                    "metadata": metadata,
                },
                fetch="cursor",
            )
            cursor.close()

        self._db.run(command=f"REFRESH TABLE {self._table_name}")

    def similarity_search(self, query: str, k: int = 4, **kwargs: Any) -> List[Document]:
        """
        Perform a similarity search on the vector store.

        You can pass in as_retriever() kwargs that allow you to parametrise search

        - "algorithm": Literal["knn", "fulltext"]. Default is "knn".

        Example:

                >>> vectorstore = CrateVectorStore(
                >>>     embeddings=OpenAIEmbeddings(),
                >>>     db=SQLDatabase.from_uri(database_uri="crate://localhost:4200"),
                >>> )
                >>> retriever = vectorstore.as_retriever(
                >>>     search_kwargs={'k': 10, "algorith": "fulltext"}
                >>> )

        """

        k = kwargs.get("k", k)
        fetch_k = kwargs.get("fetch_k", k)

        switch = kwargs.get("algorithm", "knn")
        if switch == "knn":
            results = self._db.run(
                command=f"""
                    SELECT page_content, metadata
                    FROM {self._table_name}
                    WHERE knn_match(embeddings, :embedding, :fetch_k)
                    ORDER BY _score DESC
                    LIMIT :k
                """,
                parameters={
                    "embedding": self._embeddings.embed_query(query),
                    "fetch_k": fetch_k,
                    "k": k,
                },
                fetch="cursor",
            )

        elif switch == "fulltext":
            results = self._db.run(
                command=f"""
                    SELECT page_content, metadata
                    FROM {self._table_name}
                    WHERE match(page_content, :query)
                    ORDER BY _score DESC
                    LIMIT :k
                """,
                parameters={
                    "query": query,
                    "k": k,
                },
                fetch="cursor",
            )

        else:
            raise ValueError(f"Unknown algorithm: {switch}")

        return [Document(page_content=result[0], metadata=result[1]) for result in results]

    @classmethod
    def from_texts(cls: Type[VST], texts: List[str], embedding: Embeddings, metadatas: Optional[List[dict]] = None,
                   **kwargs: Any) -> VST:
        """
        Create a new VectorStore from a list of texts.

        Example:

                # >>> from langchain_core.embeddings import OpenAIEmbeddings
                # >>> from langchain_core.vectorstores import CrateVectorStore
                # >>> from langchain_core.documents import Document
                # >>>
                # >>> texts = ["This is a test", "This is another test"]
                # >>> metadatas = [{"id": 1}, {"id": 2}]
                # >>>
                >>> vectorstore = CrateVectorStore.from_texts(
                ...     texts=texts,
                ...     embedding=OpenAIEmbeddings(),
                ...     metadatas=metadatas,
                ...     database_kwargs={"database_uri": "crate://localhost:4200"},
                ...     vectorstore_kwargs={"drop_if_exists" : True},
                ... )
                >>>
                >>> results = vectorstore.similarity_search("This is a test")
                >>> print(results)
                [Document(text='This is a test', metadata={'id': 1})]
        """

        db = SQLDatabase.from_uri(**kwargs.get("database_kwargs", {}))
        vectorstore = cls(embeddings=embedding, db=db, **kwargs.get("vectorstore_kwargs", {}))
        vectorstore.add_texts(texts, metadatas, **kwargs)
        return vectorstore
