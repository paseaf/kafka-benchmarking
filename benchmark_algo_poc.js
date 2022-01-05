const NUM_OF_MSG_TO_SEND = 100000; // can decide after testing
const TOPIC = "benchmark";
let result = {};
let numOfSuccessResponses = 0;
/**** Preload phase ****/
// (maybe a Broker) Create benchmark topic
createTopic("warmup");

/**** Warmup phase ****/
sendToBrokerAsync(warmupMessages, brokerId, TOPIC);

createTopic(TOPIC);
// 1. Producer: Generate workload
// Kafka peak throughput: 605 MB/s
const messagesToSend = prepareMessages(NUM_OF_MSG_TO_SEND);
/**
 * Message structure:
 * - id: uint // increasing order
 * - timestamp: Date // added on send
 * -
 */

// 2. Producer: Send messages to its broker (two cases, broker is leader or not)
const messagesSent = [];
for (const message of messagesToSend) {
  const messageWithMetadata = addTimestamp(message);
  // Note: set no key to send messages to topics in round-robin
  messagesSent.push(messageWithMetadata);

  const response = sendToBrokerAsync(messageWithMetadata, brokerId, TOPIC);
  if (isSuccess(response)) {
    numOfSuccessResponses++;
  }
}
result.yield = numOfSuccessResponses / NUM_OF_MSG_TO_SEND;

// 1. Consumer: read messages from topic "benchmark"
const readable = readKafkaStream(topic);
const messagesReceived = [];
// collect received messages
readable.on("data", (message) => {
  messagesReceived.push(message);
});

// analyze received messages
result.harvest = calculateHarvest(messagesReceived, messagesSent);
result.order = calculateOrder(messagesReceived);
result.duplicate = calculateDuplication(messagesReceived);
result.latency = calculateLatency(messagesSent, messagesReceived);

/**
 * 1. client1 sends, all consume
 * 2. client2 sends, all consume
 * 3. client3 sends, all consume
 */
