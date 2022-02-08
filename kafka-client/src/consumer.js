const { Kafka } = require("kafkajs");
const { clientConfigs, consumerConfigs, TOPIC } = require("../configs");

// TODO: create topic with different broker settings here. Because consumers are run before producers.
// https://kafka.js.org/docs/admin#create-topics
const kafka = new Kafka({
  clientId: clientConfigs.clientId,
  brokers: clientConfigs.brokers,
});

// Logger
const Logger = require("./Logger");

const logger = new Logger({
  filePrefix: "consumer",
  csvHeader: "acks,maxInFlightRequests,sendTime,receiveTime,id",
});
logger.init();

runConsumer(TOPIC, consumerConfigs.groupId);

// Consume
async function runConsumer(topic, groupId) {
  const consumer = kafka.consumer({ groupId: groupId });

  await consumer.connect();
  await consumer.subscribe({ topic });
  await consumer.run({
    eachMessage: async ({ message }) => {
      const receiveTime = Date.now();

      const value = JSON.parse(message.value.toString());

      const { acks, maxInFlightRequests, sendTime, id } = value;
      logger.appendRow(
        `${acks},${maxInFlightRequests},${sendTime},${receiveTime},${id}`
      );
    },
  });
}
