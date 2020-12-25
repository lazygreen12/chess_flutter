//
//  command-channel.h
//  Runner
//
//  Created by 陈智鑫 on 2020/12/24.
//

#ifndef command_channel_h
#define command_channel_h

class CommandQueue;

// 双向命令通道，一边传递给引擎，一边接收引擎的响应
class CommandChannel {

    CommandChannel();

public:
    static CommandChannel *getInstance();
    static void release();

    virtual ~CommandChannel();

    bool pushCommand(const char *cmd);
    bool popupCommand(char *buffer);
    bool pushResponse(const char *resp);
    bool popupResponse(char *buffer);

private:
    static CommandChannel *instance;

    CommandQueue *commandQueue;
    CommandQueue *responseQueue;
};

#endif /* command_channel_h */
