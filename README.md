# cmake_utils

This project demonstrates the integration of third-party libraries using CMake, with support for Linux and Android systems. Commonly used third-party libraries include `protobuf`, `openssl`, `lz4`, `zlib`, and `zstd`.

## Features

- **Reusable CMake Modules**: Pre-defined CMake modules for integrating popular third-party libraries.
- **Cross-Platform Support**: Seamless compatibility with Linux and Android platforms.
- **Custom Build Scripts**: Simplifies the integration and configuration of external dependencies.
- **Documentation**: Clear and concise instructions for integrating supported libraries.

## Getting Started

1. Clone the repository:
    ```bash
    git clone https://github.com/wzhhnet/cmake_utils.git
    ```
2. Include the utilities in your CMake project:
    ```cmake
    include(cmake_utils/some_module.cmake)
    ```
3. Follow the documentation for specific library integration instructions.

## Supported Libraries and Versions

- `protobuf` v3.20.1
- `openssl` v1.1.1w
- `lz4` v1.9.4
- `zlib` v1.3.1
- `zstd` v1.5.7

## Requirements

- CMake version 3.15 or higher.
- Compatible compiler for your platform.
- Development tools for the target platform (e.g., Android NDK for Android builds).

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please open an issue on the GitHub repository.
