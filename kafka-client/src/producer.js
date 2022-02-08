const fs = require("fs/promises");
const process = require("process");
const { Kafka } = require("kafkajs");
const { clientConfigs } = require("../configs");
const TOPIC = "benchmark";
const Logger = require("./Logger");
const logger = new Logger({
  filePrefix: "producer",
  csvHeader:
    "acks,idempotent,maxInFlightRequests,sendTime,id,success,errorMessage",
});
logger.init();

console.log("clientConfigs", clientConfigs);

const kafka = new Kafka({
  clientId: clientConfigs.clientId,
  brokers: clientConfigs.brokers,
  connectionTimeout: 10000,
  authenticationTimeout: 10000,
});

const movies = require("../dataset/movies.json");
const messagesToSend = prepareMessages(movies);

// Main
prepareTopic(kafka)
  .then(logMetadata)
  .then(() => runBenchmark(TOPIC, messagesToSend))
  .then(() => {
    logger.end();
    process.exit();
  });

// ======== Util functions =========
function logMetadata(topicMetadata) {
  const { topics } = topicMetadata;
  const brokerInfo = topics[0].partitions[0];

  fs.writeFile(`${logger.filePath}.metadata.json`, JSON.stringify(brokerInfo), {
    flag: "wx",
  });
}

async function prepareTopic(kafka) {
  const admin = kafka.admin();
  await admin.connect();

  const topicCreated = await admin.createTopics({
    topics: [{ topic: TOPIC, numPartitions: 1, replicationFactor: 3 }],
  });
  topicCreated
    ? console.log("Topic created.")
    : console.log("Topic alread exists.");

  const topicMetadata = await admin.fetchTopicMetadata({ topics: [TOPIC] });
  await admin.disconnect();

  return topicMetadata;
}

function prepareMessages(messageArray) {
  messageArray = [
    ...messageArray,
    // ...messageArray,
    // ...messageArray,
    // ...messageArray,
  ];
  return messageArray.map((value, index) => {
    return {
      id: index,
      content: value,
    };
  });
}

async function runBenchmark(topic, messages) {
  /**
   * idempotence: "Note that enabling idempotence requires max.in.flight.requests.per.
   * connection to be less than or equal to 5, retries to be greater than 0 and acks
   * must be 'all'." source: https://kafka.apache.org/28/documentation.html
   */
  const configCombinations = [
    { acks: -1, idempotent: true, maxInFlightRequests: null },
    { acks: -1, idempotent: true, maxInFlightRequests: 1 },

    { acks: -1, idempotent: false, maxInFlightRequests: null },
    { acks: -1, idempotent: false, maxInFlightRequests: 1 },
    { acks: -1, idempotent: false, maxInFlightRequests: 10 },

    { acks: 0, idempotent: false, maxInFlightRequests: null },
    { acks: 0, idempotent: false, maxInFlightRequests: 1 },
    { acks: 0, idempotent: false, maxInFlightRequests: 10 },

    { acks: 1, idempotent: false, maxInFlightRequests: null },
    { acks: 1, idempotent: false, maxInFlightRequests: 1 },
    { acks: 1, idempotent: false, maxInFlightRequests: 10 },
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
  await Promise.all(
    messages.map(async (message) => {
      const sendTime = Date.now();
      let success;
      let errorMessage = "";
      try {
        await producer.send({
          acks,
          topic: topic,
          messages: [
            {
              value: JSON.stringify({
                acks,
                idempotent,
                maxInFlightRequests,
                sendTime,
                ...message,
              }),
            },
          ],
        });
        success = true;
      } catch (e) {
        errorMessage = e.message;
        success = false;
      }
      logger.appendRow(
        `${acks},${idempotent},${maxInFlightRequests},${sendTime},${message.id},${success},${errorMessage}`
      );
    })
  );
  await producer.disconnect();
}
