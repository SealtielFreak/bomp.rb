# bomp.rb

![Ruby](https://img.shields.io/badge/Ruby-CC342D?logo=ruby)
![Gem Version](https://img.shields.io/gem/v/bomp)
![Gem Downloads (for latest version)](https://img.shields.io/gem/dtv/bomp)
![Gem download rank](https://img.shields.io/gem/rt/bomp)

A collision detection library for Ruby, works in [Ruby2D](https://github.com/ruby2d/ruby2d), [Gosu](https://github.com/gosu/gosu) and [Tic-80](https://github.com/nesbox/TIC-80)

## Introduction

A collision detection library for Ruby that makes it easy to detect collisions between 2D objects in your game or application. The library implements two popular collision detection algorithms AABB and SAT.

## Documentation
You can consult the documentation for this library in [rubydoc.info](https://www.rubydoc.info/gems/bomp/index), or you can generate the documentation with [rdoc](https://github.com/ruby/rdoc).

## Installation

### Installation from terminal

```shell
gem install bomp
```
Ensure you have the latest versions of [Ruby](https://www.ruby-lang.org/) and [Gem](https://rubygems.org/pages/download) installed on your system.

### Installation from source code

```shell
git clone https://github.com/sealtielfreak/bomp.rb.git
cd bomp.rb
```
Follow the instructions at [Install gems](https://www.bacancytechnology.com/blog/install-ruby-gems).

## Contributing

Contributions are what make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

### Setting Up Your Development Environment

Before you start contributing, it's important to set up your development environment. This includes installing necessary tools and configuring pre-commit hooks to ensure code quality.

#### Pre-Commit Hooks

To maintain code quality and consistency, we use pre-commit hooks. Follow these steps to set up pre-commit hooks in your local development environment:

1. **Install Pre-Commit**:
    - Ensure you have Python installed on your system.
    - Install pre-commit globally using pip:
      ```
      pip install pre-commit
      ```

2. **Clone the Repository** (if not already done):
   ```
   git clone https://github.com/sealtielfreak/bomp.rb.git
   cd bomp.rb
   ```

3. **Set Up Pre-Commit Hooks**:
    - In the root directory of the cloned repository, run:
      ```
      pre-commit install
      ```
    - The hook repository must have a `*.gemspec`. It will be installed via gem build `*.gemspec && gem install *.gem`. The installed package will produce an executable that will match the entry.

4. **Usage**:
    - Pre-commit hooks will now run automatically on the files you've staged whenever you commit.
    - You can manually run the hooks on all files in the repository at any time with:
      ```
      pre-commit run --all-files
      ```

### Creating a Pull Request with your changes

Now that you have done some changes and want to merge them in our repository, feel free to:

1. Create your Feature Branch (`git checkout -b feature/amazing_feature`)
2. Commit your Changes (`git commit -m "Add some AmazingFeature"`)
3. Push to the Branch (`git push origin feature/amazing_feature`)
4. Open a Pull Request