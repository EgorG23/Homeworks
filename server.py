import socket
import time
import select
import sys

HOST = '127.0.0.1'
PORT = 62024
TIMEOUT = 7

def start_server():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        server_socket.bind((HOST, PORT))
        server_socket.listen()
        server_socket.setblocking(False)

        print(f"The server is listening on the port {PORT}...")

        last_connection_time = time.time()

        while True:
            ready_sockets, _, _ = select.select([server_socket], [], [], 1)
            if ready_sockets:
                conn, addr = server_socket.accept()
                print(f"Connecting to {addr}")
                last_connection_time = time.time()
                handle_client(conn)
            elif time.time() - last_connection_time > TIMEOUT:
                print("The server did not receive connections for 7 seconds, shutting down.")
                break

def handle_client(conn):
    try:
        conn.settimeout(7)
        while True:
            data = conn.recv(1024)
            if not data:
                print("The client has disconnected.")
                break

            print(f"Received from the client: {data.decode()}")

            if data.decode() == "Lavender":
                conn.sendall("haze".encode())
                print("Sent to the client: haze")
            else:
                print("Error: the client's message is not corrected.")
                conn.sendall("Error: uncorrected message".encode())
    except socket.timeout:
        print("The waiting time for the request from the client has expired.")
    except Exception as e:
        print(f"Error: Error processing the request: {e}")
    finally:
        conn.close()
        print("The connection with the client is closed")


if __name__ == "__main__":
    try:
        start_server()
    except Exception as e:
        print(f"Server start error: {e}")
        sys.exit(1)