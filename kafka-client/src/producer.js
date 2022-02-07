const { Kafka } = require("kafkajs");
const { clientConfigs } = require("../configs");
const Logger = require("./Logger");
// TODO stress the brokers by improving throughput (e.g. 10 msgs/ms)
const logger = new Logger(
  "producer",
  "acks,idempotent,maxInFlightRequests,sendTime,id,errorCode"
);
logger.init();

console.log("clientConfigs", clientConfigs);

const kafka = new Kafka({
  clientId: clientConfigs.clientId,
  brokers: clientConfigs.brokers,
});

async function storeBrokerMetadata(logFilePath, kafka) {
  const admin = kafka.admin();
  await admin.connect();

  // Create topic
  await admin.createTopics({
    topics: [{ topic: "test", numPartitions: 1, replicationFactor: 3 }],
  });

  const { topics } = await admin.fetchTopicMetadata({ topics: ["test"] });
  const brokerInfo = topics[0].partitions[0];

  const fs = require("fs/promises");
  await fs.writeFile(
    `${logFilePath}.metadata.json`,
    JSON.stringify(brokerInfo),
    {
      flag: "wx",
    }
  );

  await admin.disconnect();
}
storeBrokerMetadata(logger.filePath, kafka);

// prepare messages
const movies = require("../dataset/movies.json");
const messagesToSend = movies.map((value, index) => {
  return {
    id: index,
    content: value,
  };
});

runBenchmark("test", messagesToSend);

// ----------------------
async function runBenchmark(topic, messages) {
  const configCombinations = [
    // { acks: -1, idempotent: true, maxInFlightRequests: null },
    // { acks: -1, idempotent: true, maxInFlightRequests: 1 },
    // { acks: -1, idempotent: true, maxInFlightRequests: 10 },

    // { acks: -1, idempotent: false, maxInFlightRequests: null },
    // { acks: -1, idempotent: false, maxInFlightRequests: 1 },
    { acks: -1, idempotent: false, maxInFlightRequests: 10 },

    // { acks: 0, idempotent: false, maxInFlightRequests: null },
    // { acks: 0, idempotent: false, maxInFlightRequests: 1 },
    // { acks: 0, idempotent: false, maxInFlightRequests: 10 },

    // { acks: 1, idempotent: false, maxInFlightRequests: null },
    // { acks: 1, idempotent: false, maxInFlightRequests: 1 },
    // { acks: 1, idempotent: false, maxInFlightRequests: 10 },
  ];

  for (const configCombination of configCombinations) {
    console.log("Running with configs combination:\n", configCombination);
    await runProducer(topic, messages, configCombination).catch(console.error);
    console.log("Done!");
  }
}

async function runProducer(
  topic,
  messages,
  { acks, idempotent, maxInFlightRequests }
) {
  // Producing
  const producer = kafka.producer({ idempotent, maxInFlightRequests });

  await producer.connect();

  // send messages
  const extendedMessages = messages
    .map((message) => {
      return { acks, idempotent, maxInFlightRequests, ...message };
    })
    .map(JSON.stringify);

  const times = [];
  for (const extendedMessage of extendedMessages) {
    const sendTime = Date.now() + "";
    const responses = await producer.send({
      acks,
      topic: topic,
      messages: [{ key: sendTime, value: extendedMessage }],
    });
    const sendErrorCode = responses[0].errorCode;
    times.push(sendTime);
    // logger.appendRow(
    //   // `${acks},${idempotent},${maxInFlightRequests},${sendTime},${extendedMessage.id},${sendErrorCode}`
    //   `${acks},${idempotent},${maxInFlightRequests},${sendTime},${extendedMessage.id},${sendErrorCode}`
    // );
  }
  console.log(times);
  logger.end();
  await producer.disconnect();
}
