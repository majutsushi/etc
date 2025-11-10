#!/usr/bin/swift
// Inspired by https://github.com/azone/uti-convert
// Compile with 'swiftc uti-to-mime.swift -o ~/bin/uti-to-mime'

import UniformTypeIdentifiers

while let line = readLine() {
    let type = UTType(line)
    let mimeType = type?.preferredMIMEType ?? "application/octet-string"
    print(mimeType)
}
