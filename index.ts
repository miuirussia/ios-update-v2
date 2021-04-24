import Database from 'better-sqlite3';
import { Telegram } from 'telegraf';
import Parser from 'rss-parser';

const ALLOW_LIST = ['iOS', 'iPadOS', 'watchOS', 'tvOS', 'macOS'];
const WAIT_TIMEOUT_MS: number = 5 * 1000;
const BOT_API_KEY = process.env['BOT_API_KEY'];
const BOT_CHANNEL_ID = process.env['BOT_CHANNEL_ID'];

class EnvironmentError extends Error {};

if (!BOT_API_KEY) {
  throw new EnvironmentError('BOT_API_KEY is not defined');
}

if (!BOT_CHANNEL_ID) {
  throw new EnvironmentError('BOT_CHANNEL_ID is not defined');
}

const parser = new Parser();
const db = new Database('./data/state.db');
const bot = new Telegram(BOT_API_KEY);

db.prepare(
  `CREATE TABLE IF NOT EXISTS already_send (
    \`id\` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    \`message\` varchar(255) NOT NULL
   );`,
).run();

const waitFor = (timeout: number): Promise<void> => new Promise(resolve => setTimeout(resolve, timeout));

const launch = async () => {
  const feed = await parser.parseURL('https://developer.apple.com/news/releases/rss/releases.rss');
  for (const item of feed.items) {
    const message = `${item.title} is released`;

    if (!ALLOW_LIST.some(start => message.startsWith(start))) continue;

    const getMessageStmt = db.prepare('SELECT * FROM already_send WHERE message = ?;');
    console.log(new Date(), `${item.title} is released...`);
    if (!getMessageStmt.all(message).length) {
      try {
        console.log(new Date(), `Sending message to telegram channel: ${message}`);
        await bot.sendMessage(BOT_CHANNEL_ID, message);
        const insertMessageStmt = db.prepare('INSERT INTO already_send (message) VALUES (?)');
        insertMessageStmt.run(message);
        console.log(`   ...users notified`);
      } catch (error) {
        console.log('   ...failed to send message: ', message);
        console.error(error);
      }
      await waitFor(WAIT_TIMEOUT_MS);
    } else {
      console.log(`   ...message already sent`);
    }
  }
};

launch();
