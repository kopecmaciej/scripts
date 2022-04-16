package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var mongoUri string = "mongodb://localhost:27017,localhost:27018,localhost:27019/db-test?replicaSet=rs0"

var ctx = context.Background()

func main() {
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoUri))

	if err != nil {
		log.Fatal(err)
	}

	defer client.Disconnect(ctx)

	db := client.Database("db-test")

	err = db.CreateCollection(ctx, "coll_test")

	if err != nil {
		log.Fatal(err)
	}

	testColl := db.Collection("coll_test")

	defer testColl.Drop(ctx)

	for i := 0; i < 1000; i++ {

		insertValue(testColl, i)
		time.Sleep(2 * time.Second)

	}
}

func insertValue(collection *mongo.Collection, value int) {
	res, err := collection.InsertOne(ctx, bson.D{{Key: "count", Value: value}})

	var _id interface{}

	if res != nil {
		_id = res.InsertedID
	} else {
		res, err := collection.InsertOne(ctx, bson.D{{Key: "count", Value: value}})

		if err != nil {
			log.Fatal("Something go wrong with inserting document")
			return
		}
		_id = res.InsertedID

	}
	filter := bson.D{{Key: "_id", Value: _id}}

	var result bson.D
	err = collection.FindOne(ctx, filter).Decode(&result)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(result)
}
