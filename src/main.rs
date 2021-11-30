#[macro_use] extern crate log;
#[macro_use] extern crate strum_macros;

use structopt::StructOpt;


mod calico;

#[derive(StructOpt)]
struct Cli {
    action: Action,
    ip: String,
}

#[derive(Debug, EnumString)]
#[strum(serialize_all = "kebab-case")]
enum Action {
    Ban,
    Unban,
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    std::env::var("RUST_LOG").map_err(|_| {
        std::env::set_var("RUST_LOG", "debug,fail2ban-calico=debug");
    }).unwrap_or_default();
    env_logger::init();

    let args = Cli::from_args();

    match args.action {
        Action::Ban => {
            match calico::all::ban(&args.ip).await {
                Ok(()) => {
                    info!("Ip `{}` banned successfully", &args.ip)
                },
                Err(e) => {
                    error!("Error when try to ban ip `{}`: {}", &args.ip, e);
                }
            }
        },
        Action::Unban => {
            match calico::all::unban(&args.ip).await {
                Ok(()) => {
                    info!("Ip `{}` unbanned successfully", &args.ip)
                },
                Err(e) => {
                    error!("Error when try to unban ip `{}`: {}", &args.ip, e);
                }
            }
        },
    }
}

