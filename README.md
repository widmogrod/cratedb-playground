# cratedb-playground
Have fun with cratedb

## Getting started

```
pip install crash
```

### Docker compose
```
docker-compose -f infra/local-instance/docker-compose.yml up

or 

docker run -d -p 4200:4200 -p 4300:4300 -p 5432:5432 --env CRATE_HEAP_SIZE=1g crate \
    crate -Cnetwork.host=_site_
```

### AWS Infrastructure
```
cd infra/aws-instance
terafform init
terraform plan
terraform apply
```


## Notes
- Terraform work but healcheck fails and I cannot connect to cluster
  - problem got resolved when I used subnet connected to IGW
    - but this also revealed https://community.cratedb.com/t/issue-connecting-to-cratedb-cloud-cluster-from-local-machine/1707/11
    - there is undocumented `--verify-ssl=False`
  - psql works fine

- Docker compose with few instances and with single instance on MacOS + colima I had to do, to make it work
  https://github.com/abiosoft/colima/issues/384
- Cloud shared works.

- Crate:
  - SQL import files via URL, cool feature! 

- Crash: 
  - works fine  

- Cloud/Console:
  - console.cratedb.cloud SQL is unpleasant on Safari // I had to write this select in text editor and copy it in SELECT * FROM guestbook.countries
  - edge regions sounds cool, but I'm not sure what it is and how it works, I would love to see some documentation

- CrateDB/Console:
  - SQL execution is cool, if there is a way I would love to restrict access to it, especially for production
  - After importing guestbook countries, when running SELECT, it shows table and in geometry it links to http://geojson.io/#data=data:application/json,%7B%22value%22%3A%7B%22coordinates%22%3A%5B%5B%5B%5B16.326528%2C-5.87747%5D%2C%5B16.57318%2C-6.622645%5D%2C%5B16.860191%2C-7.222298%5D%2C%5B17.089996%2C-7.545689%5D%2C%5B17.47297%2C-8.068551%5D%2C%5B18.134222%2C-7.987678%5D%2C%5B18.464176%2C-7.847014%5D%2C%5B19.016752%2C-7.988246%5D%2C%5B19.166613%2C-7.738184%5D%2C%5B19.417502%2C-7.155429%5D%2C%5B20.037723%2C-7.116361%5D%2C%5B20.091622%2C-6.94309%5D%2C%5B20.601823%2C-6.939318%5D%2C%5B20.514748%2C-7.299606%5D%2C%5B21.728111%2C-7.290872%5D%2C%5B21.746456%2C-7.920085%5D%2C%5B21.949131%2C-8.305901%5D%2C%5B21.801801%2C-8.908707%5D%2C%5B21.875182%2C-9.523708%5D%2C%5B22.208753%2C-9.894796%5D%2C%5B22.155268%2C-11.084801%5D%2C%5B22.402798%2C-10.993075%5D%2C%5B22.837345%2C-11.017622%5D%2C%5B23.456791%2C-10.867863%5D%2C%5B23.912215%2C-10.926826%5D%2C%5B24.017894%2C-11.237298%5D%2C%5B23.904154%2C-11.722282%5D%2C%5B24.079905%2C-12.191297%5D%2C%5B23.930922%2C-12.565848%5D%2C%5B24.016137%2C-12.911046%5D%2C%5B21.933886%2C-12.898437%5D%2C%5B21.887843%2C-16.08031%5D%2C%5B22.562478%2C-16.898451%5D%2C%5B23.215048%2C-17.523116%5D%2C%5B21.377176%2C-17.930636%5D%2C%5B18.956187%2C-17.789095%5D%2C%5B18.263309%2C-17.309951%5D%2C%5B14.209707%2C-17.353101%5D%2C%5B14.058501%2C-17.423381%5D%2C%5B13.462362%2C-16.971212%5D%2C%5B12.814081%2C-16.941343%5D%2C%5B12.215461%2C-17.111668%5D%2C%5B11.734199%2C-17.301889%5D%2C%5B11.640096%2C-16.673142%5D%2C%5B11.778537%2C-15.793816%5D%2C%5B12.123581%2C-14.878316%5D%2C%5B12.175619%2C-14.449144%5D%2C%5B12.500095%2C-13.5477%5D%2C%5B12.738479%2C-13.137906%5D%2C%5B13.312914%2C-12.48363%5D%2C%5B13.633721%2C-12.038645%5D%2C%5B13.738728%2C-11.297863%5D%2C%5B13.686379%2C-10.731076%5D%2C%5B13.387328%2C-10.373578%5D%2C%5B13.120988%2C-9.766897%5D%2C%5B12.87537%2C-9.166934%5D%2C%5B12.929061%2C-8.959091%5D%2C%5B13.236433%2C-8.562629%5D%2C%5B12.93304%2C-7.596539%5D%2C%5B12.728298%2C-6.927122%5D%2C%5B12.227347%2C-6.294448%5D%2C%5B12.322432%2C-6.100092%5D%2C%5B12.735171%2C-5.965682%5D%2C%5B13.024869%2C-5.984389%5D%2C%5B13.375597%2C-5.864241%5D%2C%5B16.326528%2C-5.87747%5D%5D%5D%2C%5B%5B%5B12.436688%2C-5.684304%5D%2C%5B12.182337%2C-5.789931%5D%2C%5B11.914963%2C-5.037987%5D%2C%5B12.318608%2C-4.60623%5D%2C%5B12.62076%2C-4.438023%5D%2C%5B12.995517%2C-4.781103%5D%2C%5B12.631612%2C-4.991271%5D%2C%5B12.468004%2C-5.248362%5D%2C%5B12.436688%2C-5.684304%5D%5D%5D%5D%2C%22type%22%3A%22MultiPolygon%22%7D%2C%22type%22%3A%22geo_shape%22%7D which does not render properly
    - is it needed?

- [crate-sample-apps](crate-sample-apps)
  - Go implementation works fine
    - It could be more consistent with methods receivers that are sometime pointers and sometimes values

- [rag](rag)
  - Building RAG search on crate documentation I had problem with
    - When using `crate.client` python package throws error and cratedb search in documentation is not helpful
      ```
      Removed server https://localhost:4200 from active pool
      ```
    - SQLAlchemy and pandas works fine...
    - `crash` CLI also works fine...
  - A quite flustrating expirence I had with fulltext search
    ```
    CREATE TABLE IF NOT EXISTS "doc"."docs_3" (
      "title" TEXT,
      "url" TEXT,
      "html" TEXT INDEX USING FULLTEXT WITH (
        analyzer = 'english'
      )
    )
    ```
    This is SQL that I RUN
    ```
    select d.* 
    from doc.docs_3 as d
    where match("d"."html" , "find me crate")
    limit 100;
    ```
    I get error:
    ```
    io.crate.exceptions.ColumnUnknownException: Column find me crate unknown 
    ```
    Where error should be something along the lines use `'` maybe you want to use single quotes?
  
  - Suggestion to AdminUI, allow binding params in SQL queries, so I can use `?` instead of `find me crate`


## Bugs?

- I sent invitation to new user, and when I clicked on link in email it shows me "Invitation not found or expired." message.
  In the console I see that invitation is valid for 24h, but I clicked on it in less than 1h.
  I use Safari and I was logged in to CrateDB console
  Using Chrome in incognito shows login page, no info what to do with invitation.

## Some ideas

- JobScheduler in terraform would be awesome
- Budget / costs overview on timeline
- Permission system and roles in cloud to run certain operations


## What queries to ask when using RAG?

- what JOB scheduler are (in context of CrateDB) using?
- what are edge regions?

## To learn

- What are edge regions
- what and how BLOB tables work?
- How AWS marketplace works, and why I cannot see deployment in my account?
- How Cloud console

## Other
- What are limits of scalability?


