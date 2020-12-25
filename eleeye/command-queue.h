//
//  command-queue.hpp
//  Runner
//
//  Created by 陈智鑫 on 2020/12/24.
//

#ifndef command_queue_h
#define command_queue_h

// 命令队列
class CommandQueue {

    enum {
        MAX_COMMAND_COUNT = 128,
        COMMAND_LENGTH = 2048,
    };

    char commands[MAX_COMMAND_COUNT][COMMAND_LENGTH];
    int readIndex, writeIndex;

public:
    CommandQueue();

    bool write(const char *command);
    bool read(char *dest);
};

#endif /* command_queue_h */
