from dataclasses import dataclass, field
from enum import Enum
from typing import List, Dict, Optional, Any

# pip install dataclass-wizard
from dataclass_wizard import JSONWizard, json_field


class FieldType(Enum):
    NUMBER = 'number'
    STRING = 'string'
    CATEGORY = 'category'
    TEXT = 'text'
    URL = 'url'
    IMAGE_PATH = 'image_path'
    IMAGE_BYTE = 'image_byte'
    PER_MODEL_BOOLEAN = 'per_model_boolean'
    PER_MODEL_NUMBER = 'per_model_number'
    PER_MODEL_CATEGORY = 'per_model_category'
    PER_RATING_STRING = 'per_rating_string'
    PER_RATING_PER_MODEL_CATEGORY = 'per_rating_per_model_category'
    BASE = 'base'


@dataclass
class CustomFieldSchema:
    name: str
    type: FieldType
    domain: Optional[List[str]] = None


@dataclass
class Model:
    name: str


@dataclass
class RaterScore:
    is_flipped: bool
    score: float
    rationale: str
    rating_label: Optional[str] = None  # Optional to accommodate missing 'rating_label' from the second type structure.


@dataclass
class Rational:
    rationale: str
    paraphrased_rationales: List[str]
    similarities: List[float]


@dataclass
class RationaleCluster:
    title: str


@dataclass
class Example:
    index: int
    input_text: str
    tags: List[str]
    output_text_a: str
    output_text_b: str
    score: float
    custom_fields: Dict[str, Any] = None
    individual_rater_scores: List[RaterScore] = field(default_factory=list)
    rationale_list: List[Rational] = field(default_factory=list)


@dataclass
class Metadata:
    source_path: str
    custom_fields_schema: List[CustomFieldSchema]


@dataclass
class LLMComparatorData(JSONWizard):
    class _(JSONWizard.Meta):
        # Sets the target key transform to use for serialization;
        # defaults to `camelCase` if not specified.
        key_transform_with_dump = 'SNAKE'
        skip_defaults = True

    metadata: Metadata
    models: List[Model]
    examples: List[Example]
    rationale_clusters: Optional[List[RationaleCluster]] = field(default_factory=list)


if __name__ == "__main__":
    import json
    from deepdiff import DeepDiff

    with open("j.json") as f:
        data = json.load(f)

        with open("j1.json", "w") as f2:
            f2.write(json.dumps(data))

        llm_comparator_data = LLMComparatorData.from_dict(data)
        print(llm_comparator_data)

        with open("j2.json", "w") as f2:
            f2.write(llm_comparator_data.to_json())

        data_2 = json.loads(llm_comparator_data.to_json())

        diff = DeepDiff(data, data_2)
        print(diff)

