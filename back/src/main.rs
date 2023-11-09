use tonic::{transport::Server, Request, Response, Status};

use hello_world::hello_service_server::{HelloService, HelloServiceServer};
use hello_world::{HelloResponse, HelloRequest};

pub mod hello_world {
    tonic::include_proto!("hello");
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

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;
    let greeter = MyGreeter::default();

    Server::builder()
        .add_service(HelloServiceServer::new(greeter))
        .serve(addr)
        .await?;

    Ok(())
}
