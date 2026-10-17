import json
from pathlib import Path
import subprocess
import sys
import tempfile
import textwrap
import unittest


AGENTS_ROOT = Path(__file__).resolve().parents[1]
WRAPPER = AGENTS_ROOT / ".local/bin/agent-mcp-callback"
EXTENSION = "dev.alafia/agent-callback"


class AgentMcpCallbackTest(unittest.TestCase):
    def test_injects_capability_and_delivers_callback(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            delivery = root / "delivery.json"
            agent_msg = root / "agent-msg"
            agent_msg.write_text(textwrap.dedent(f"""\
                #!{sys.executable}
                import json
                from pathlib import Path
                import sys

                if sys.argv[1:] == ["self"]:
                    print("codex:test-thread")
                elif sys.argv[1:4] == ["send", "--notification", "codex:test-thread"]:
                    Path({str(delivery)!r}).write_text(json.dumps(sys.argv[4:]))
                else:
                    raise SystemExit(2)
            """))
            agent_msg.chmod(0o755)
            server = root / "server.py"
            server.write_text(textwrap.dedent("""\
                import json
                import socket
                import sys

                for line in sys.stdin:
                    request = json.loads(line)
                    params = request.get("params", {})
                    if request.get("method") == "tools/call":
                        callback = params["_meta"]["dev.alafia/agent-callback"]
                        frame = {
                            "authorization": callback["authorization"],
                            "version": 1,
                            "source": "test-mcp",
                            "event": "finished",
                            "data": {"ok": True},
                        }
                        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
                            client.connect(callback["endpoint"])
                            client.sendall(json.dumps(frame).encode() + b"\\n")
                            acknowledgement = json.loads(client.makefile().readline())
                        result = {"callback": callback, "ack": acknowledgement}
                    else:
                        result = {"capabilities": params.get("capabilities", {})}
                    print(json.dumps({"jsonrpc": "2.0", "id": request["id"], "result": result}), flush=True)
            """))
            requests = "\n".join((
                json.dumps({
                    "jsonrpc": "2.0", "id": 1, "method": "initialize",
                    "params": {"capabilities": {}},
                }),
                json.dumps({
                    "jsonrpc": "2.0", "id": 2, "method": "tools/call",
                    "params": {"name": "test", "arguments": {}},
                }),
                "",
            ))
            result = subprocess.run(
                [
                    sys.executable, str(WRAPPER),
                    "--agent-msg", str(agent_msg), "--",
                    sys.executable, str(server),
                ],
                input=requests,
                capture_output=True,
                text=True,
                check=False,
                timeout=15,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            responses = [json.loads(line) for line in result.stdout.splitlines()]
            advertised = responses[0]["result"]["capabilities"]["extensions"]
            self.assertEqual(advertised[EXTENSION]["version"], "0.1")
            callback = responses[1]["result"]["callback"]
            self.assertEqual(callback["transport"], "unix")
            self.assertTrue(responses[1]["result"]["ack"]["ok"])
            sent = json.loads(delivery.read_text())
            self.assertEqual(len(sent), 1)
            self.assertEqual(json.loads(sent[0])["event"], "finished")
            self.assertFalse(Path(callback["endpoint"]).exists())


if __name__ == "__main__":
    unittest.main()
