use tonic::Streaming;
use tonic::{transport::Server, Request, Response, Status};
use tokio::sync::mpsc;
use tokio_stream::{wrappers::ReceiverStream, StreamExt};

use hello_world::hello_service_server::{HelloService, HelloServiceServer};
use hello_world::{HelloResponse, HelloRequest};

use chat::chat_service_server::{ChatService, ChatServiceServer};
use chat::ChatMessage;

pub mod hello_world {
    tonic::include_proto!("hello");
}

pub mod chat {
    tonic::include_proto!("chat");
}

#[derive(Debug, Default)]
pub struct MyGreeter {}

#[tonic::async_trait]
impl HelloService for MyGreeter {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>,
    ) -> Result<Response<HelloResponse>, Status> {
        println!("Got a request: {:?}", request);

        let reply = hello_world::HelloResponse {
            message: format!("Hello {}!", request.into_inner().name).into(),
        };

        Ok(Response::new(reply))
    }
}

#[derive(Debug, Default)]
pub struct Chat {}

#[tonic::async_trait]
impl ChatService for Chat {
    type ChatStream = ReceiverStream<Result<ChatMessage, Status>>;

    async fn chat(
        &self,
        request: Request<Streaming<ChatMessage>>,
    ) -> Result<Response<Self::ChatStream>, Status> {
        println!("Got a request: {:?}", request);
        let mut in_stream = request.into_inner();
        let (tx, rx) = mpsc::channel(128);

        tokio::spawn(async move {
            while let Some(result) = in_stream.next().await {
                match result {
                    Ok(msg) => {
                        println!("Got a message: {:?}", msg);
                        tx.send(Ok(msg)).await.unwrap();
                    },
                    Err(e) => {
                        println!("Error: {:?}", e);
                        tx.send(Err(Status::aborted("aborted"))).await.unwrap();
                    }
                }
            }
        });

        let out_stream = ReceiverStream::new(rx);

        Ok(Response::new(out_stream))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;
    let greeter = MyGreeter::default();
    let chat = Chat::default();

    Server::builder()
        .add_service(HelloServiceServer::new(greeter))
        .add_service(ChatServiceServer::new(chat))
        .serve(addr)
        .await?;

    Ok(())
}
