CC = xcrun clang

TARGET = media-key-router
SRCS = main.m

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) -fobjc-arc -o $(TARGET) $(SRCS) -framework AppKit -framework Foundation

run: $(TARGET)
	./$(TARGET) play-pause

clean:
	rm -f $(TARGET)
