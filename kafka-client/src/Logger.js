const fs = require("fs/promises");
const fsSync = require("fs");
const path = require("path");

const logDir = "/home/ansible/logs";

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
    this.filePath = "";
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
      `${date.getUTCSeconds()}`;

    if (!fsSync.existsSync(logDir)) {
      fsSync.mkdirSync(logDir);
    }

    this.filePath = path.join(logDir, `${this.filePrefix}-${datetime}.csv`);
    const logFd = await fs.open(this.filePath, "ax");

    const writable = logFd.createWriteStream(this.filePath);

    this.writable = writable;

    this.writable.write(this.csvHeader + "\n");
  }

  appendRow(row) {
    this.writable.write(`${row}\n`);
  }

  end() {
    this.writable.end();
  }
}

module.exports = Logger;
