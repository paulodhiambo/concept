FROM ghcr.io/graalvm/native-image-community:21 AS build
RUN microdnf install -y maven findutils
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn -Pnative native:compile -DskipTests

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=build /app/target/concept .
EXPOSE 8080
ENTRYPOINT ["./concept"]
