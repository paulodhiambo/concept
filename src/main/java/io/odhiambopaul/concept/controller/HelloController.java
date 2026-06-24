package io.odhiambopaul.concept.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/hello")
public class HelloController {
    String message = "Hello World";

    @GetMapping
    public ResponseEntity<?> hello() {
        return new ResponseEntity<>(Map.of(
                "message", message
        ), HttpStatus.OK);
    }
}
