CC = xcrun clang

TARGET = trackpad-haptic
SRCS = main.m

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) -o $(TARGET) $(SRCS) -framework AppKit
run: $(TARGET)
	./$(TARGET)

# Clean the build
clean:
	rm -f $(TARGET)
