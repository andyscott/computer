# Compiler
CC = xcrun clang

# Output binary name
TARGET = google-meet-escape-artist

# Source files
SRCS = main.c

# Build the target
all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) -o $(TARGET) $(SRCS) -F/System/Library/PrivateFrameworks -framework SkyLight -framework Foundation -framework Carbon
run: $(TARGET)
	./$(TARGET)

# Clean the build
clean:
	rm -f $(TARGET)
