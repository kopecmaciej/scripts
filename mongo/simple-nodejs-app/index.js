const { MongoClient } = require("mongodb");

//rs.initiate({_id:"rs0",version:1,members:[{_id:1,host:"mongo-0-a:27017",priority:3},{_id:2,host:"mongo-0-b:27017",priority:2},{_id:3,host:"mongo-0-c:27017",priority:1}]})
const url = `mongodb://127.0.10.1:27017,127.0.10.2:27017,127.0.10.3:27017/db-test?replicaSet=rs0`;

const mongo = async () => {
  const client = new MongoClient(url);
  await client.connect();

  const db = client.db("db-test");

  const test_coll = db.collection("test_coll");

  test_coll.createIndex({ count: 1 }, { unique: true });

  await test_coll.deleteMany({});

  if (test_coll) console.log("connected");

  let count = 0;

  for (let i = 0; i < 1000; i++) {
    const value = `count: ${count}`;
    console.log(value);
    const doc = { count: value };
    try {
      await test_coll.insertOne(doc);
    } catch (err) {
      console.log(err);
      await wait();
      await test_coll.insertOne(doc);
    }

    let result;
    try {
      result = test_coll.find({ count: value });
    } catch (err) {
      console.error(err);
      await wait();
      result = test_coll.find({ count: value });
    }

    let end;

    for await (const doc of result) {
      end = doc;
    }

    console.log(end);

    async function wait() {
      return new Promise((res) => {
        count++;
        setTimeout(() => res(""), 3000);
      });
    }
    await wait();
  }
  await client.close();
  return;
};

mongo()
  .then(console.log("test_compoleted"))
  .catch((err) => console.error(err));
