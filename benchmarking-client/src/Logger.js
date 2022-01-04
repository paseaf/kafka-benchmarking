const fs = require("fs/promises");

class Logger {
  /**
   *
   * @param {string} filePrefix Example: "producer", "consumer"
   * @param {string} csvHeader Example: "timestamp,id,content"
   */
  constructor(filePrefix, csvHeader) {
    this.filePrefix = filePrefix;
    this.csvHeader = csvHeader;
    this.writable = null;
  }

  async init() {
    const date = new Date();

    const datetime =
      `${date.getUTCFullYear()}` +
      `${date.getUTCMonth() < 9 ? 0 : ""}` +
      `${date.getUTCMonth() + 1}` +
      `${date.getUTCDate() < 9 ? 0 : ""}` +
      `${date.getUTCDate()}` +
      "-" +
      `${date.getUTCHours() < 9 ? 0 : ""}` +
      `${date.getUTCHours()}` +
      "-" +
      `${date.getUTCMinutes() < 9 ? 0 : ""}` +
      `${date.getUTCMinutes()}` +
      "-" +
      `${date.getUTCSeconds() < 9 ? 0 : ""}` +
      `${date.getUTCSeconds()}` +
      ".csv";

    const fileName = `./logs/${this.filePrefix}-${datetime}`;
    const logFd = await fs.open(fileName, "ax");

    const writable = logFd.createWriteStream(fileName);

    this.writable = writable;

    switch (this.filePrefix) {
      case "producer":
        this.writable.write(
          "acks,idempotent,maxInFlightRequests,timestamp,id,errorCode\n"
        );
        break;
      case "consumer":
        throw Error("To be implemented");
        break;
      default:
        throw Error("filePrefix must be producer or consumer");
        break;
    }
  }

  appendRow({
    acks,
    idempotent,
    maxInFlightRequests,
    timestamp,
    id,
    errorCode,
  }) {
    this.writable.write(
      `${acks},${idempotent},${maxInFlightRequests},${timestamp},${id},${errorCode}\n`
    );
  }

  end() {
    this.writable.end();
  }
}

module.exports = Logger;
