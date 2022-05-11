# Build Stage
FROM --platform=linux/amd64 ubuntu:22.04 as builder

ENV DEBIAN_FRONTEND=noninteractive
## Install build dependencies.
RUN apt-get update && apt-get install -y cmake clang llvm curl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . $HOME/.cargo/env
RUN ~/.cargo/bin/rustup default nightly
RUN ~/.cargo/bin/cargo install cargo-fuzz

## Add source code to the build stage.
ADD . /rust-bio/

WORKDIR /rust-bio/fuzz/
RUN ~/.cargo/bin/cargo fuzz build

FROM --platform=linux/amd64 ubuntu:22.04

COPY --from=builder /rust-bio/fuzz/target/x86_64-unknown-linux-gnu/release/banded_aligner /
COPY --from=builder /rust-bio/fuzz/target/x86_64-unknown-linux-gnu/release/myers_matching /