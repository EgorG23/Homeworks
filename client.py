import socket
import time

HOST = '127.0.0.1'
PORT = 62024
TIMEOUT = 7

def start_client():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
        client_socket.settimeout(TIMEOUT)
        try:
            client_socket.connect((HOST, PORT))
            print(f"Connected to the server {HOST}:{PORT}")

            for i in range(20):
                if (i < 10):
                     message = "lavender"
                else:
                     message = "Lavender"
                print(f"Sent to the server: {message}")
                client_socket.sendall(message.encode())

                try:
                    data = client_socket.recv(1024)
                    if data:
                        print(f"Recieved from the server: {data.decode()}")
                    else:
                        print("Error: the empty answer from the server")
                        break
                except socket.timeout:
                    print("Error: no time to wait the answer from the server")
                    break

                time.sleep(3)
        except (socket.timeout, ConnectionRefusedError) as e:
            print(f"Error: failed to connect to the server or the response timeout has expired. ({e})")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    start_client()
