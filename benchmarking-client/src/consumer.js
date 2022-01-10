const { Kafka } = require("kafkajs");
const { clientConfigs, consumerConfigs } = require("../configs");

// TODO: create topic with different broker settings here. Because consumers are run before producers.
// https://kafka.js.org/docs/admin#create-topics
const kafka = new Kafka({
  clientId: clientConfigs.clientId,
  brokers: clientConfigs.brokers,
});

// Logger
const Logger = require("./Logger");

const logger = new Logger(
  "consumer",
  "acks,idempotent,maxInFlightRequests,sendTime,receiveTime,id"
);
logger.init();

// Consume
async function runConsumer(topic, groupId) {
  const consumer = kafka.consumer({ groupId: groupId });

  await consumer.connect();
  await consumer.subscribe({ topic });
  await consumer.run({
    eachMessage: async ({ message }) => {
      const receiveTime = Date.now();

      const value = JSON.parse(message.value.toString());
      console.log(value);

      const { acks, idempotent, maxInFlightRequests, sendTime, id } = value;
      logger.appendRow(
        `${acks},${idempotent},${maxInFlightRequests},${sendTime},${receiveTime},${id}`
      );
    },
  });
}

runConsumer("test", consumerConfigs.groupId);
