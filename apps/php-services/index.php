<?php
/**
 * PHP Laravel application entry point
 * This is a placeholder. Replace with your actual Laravel application.
 */

// For development with docker/podman, you can start with a simple index
if ($_SERVER['REQUEST_URI'] === '/' || $_SERVER['REQUEST_URI'] === '') {
    header('Content-Type: application/json');
    echo json_encode([
        'message' => 'PHP service is running!',
        'timestamp' => date('c'),
        'path' => $_SERVER['REQUEST_URI'] ?? '/'
    ]);
} else {
    // Simple router for testing
    header('Content-Type: application/json');
    http_response_code(200);
    echo json_encode([
        'message' => 'PHP service is running!',
        'path' => $_SERVER['REQUEST_URI'] ?? '/',
        'method' => $_SERVER['REQUEST_METHOD'] ?? 'GET'
    ]);
}
