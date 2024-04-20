import { Controller } from "@hotwired/stimulus"
import { Terminal } from '@xterm/xterm';
import { FitAddon } from 'xterm-addon-fit';
import consumer from "../channels/consumer"


// Connects to data-controller="console"
export default class extends Controller {
  static values = { id: String }
  intervalId = null; // Store the interval ID for clearing later
  connect() {
    console.log("Connected to console controller");
    console.log("Container ID: " + this.idValue);
    this.setupTerminal();
    this.createChannel();
    this.setupTerminalHotkeys();
    this.startLogFetching();
  }
  disconnect() {
    this.stopLogFetching(); // Ensure to clean up on disconnect
  }

  setupTerminal() {
    this.terminal = new Terminal({
      convertEol: true,
      fontFamily: `"Fira Code", monospace`,
      fontSize: 18,
      cursorBlink: true,
      scrollback: 100, // Set scrollback to 100 lines
    });

    const fitAddon = new FitAddon();
    this.terminal.loadAddon(fitAddon);
    this.terminal.open(this.element);
    fitAddon.fit();
    window.addEventListener('resize', () => fitAddon.fit());
  }

  createChannel() {
    this.dockerConsole = consumer.subscriptions.create({ channel: "ContainerChannel", id: this.idValue }, {
      connected: () => {
        console.log("Connected to container channel");
        this.fetchLogs(); // Fetch logs immediately
      },
      disconnected: () => {
        console.log("Disconnected from container channel");
      },
      received: (data) => {
        console.log("Received data", data.output);

        
        data.output.forEach((line) => {
          this.terminal.writeln(line);
        });

        this.trimTerminalBuffer();
      },
    });
  }

  trimTerminalBuffer() {
    const terminalBuffer = this.terminal.buffer.active;
    const linesToTrim = terminalBuffer.length - 100;
  
    if (linesToTrim > 0) {
      this.terminal.buffer.active.trimStart(linesToTrim);
    }
  }

  setupTerminalHotkeys() {
    this.terminal.onKey(({ key, domEvent }) => {
      if (domEvent.key === 'Enter') {
        this.terminal.write('\r\n');
        this.sendCommand(key, this.idValue);
      } else if (domEvent.ctrlKey && domEvent.key === 'l') {
        this.terminal.clear();
      } else {
        this.terminal.write(key);
      }
    });
  }

  sendCommand(command, id) {
    this.dockerConsole.perform('receive', { command: command, id: id });
  }

  startLogFetching() {
    this.intervalId = setInterval(() => {
      this.fetchLogs();
    }, 1000);
  }

  stopLogFetching() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  fetchLogs() {
    // Perform the 'fetch_logs' action on the channel
    this.dockerConsole.perform('fetch_logs', { id: this.idValue });
  }
}
