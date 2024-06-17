const express = require('express');
const bodyParser = require('body-parser');


const socketio = require('socket.io');
const e = require('express');
var app = express();

const router = require('./router');
app.use(router);

app.use(bodyParser.urlencoded({ extended: true }));


app.use(bodyParser.json());


var server = app.listen(3000,()=>{
    console.log('Server is running')
})

//Chat Server

var io = socketio(server);

io.on('connection',function(socket) {

    console.log(`Connection : SocketId = ${socket.id}`)

    var userName = '';
    
    socket.on('subscribe', function(data) {
        console.log('subscribe trigged')
        var room_data = data
        userName = room_data.userName;
        const roomName = room_data.roomName;
    
        socket.join(`${roomName}`)
        console.log(`Username : ${userName} joined Room Name : ${roomName}`)
        
        io.to(`${roomName}`).emit('newUserToChatRoom', { userName });

    })

    socket.on('unsubscribe',function(data) {
        console.log('unsubscribe trigged')
        const room_data = data
        const userName = room_data.userName;
        const roomName = room_data.roomName;
    
        console.log(`Username : ${userName} leaved Room Name : ${roomName}`)
        // flutter kodu: socket.broadcast.to(`${roomName}`).emit('userLeftChatRoom', { userName })
        io.to(`${roomName}`).emit('userLeftChatRoom', { userName });
        socket.leave(`${roomName}`)
    })

    socket.on('newMessage',function(data) {
        console.log('newMessage triggered')

        const messageData = data
        const messageContent = messageData.messageContent
        const roomName = messageData.roomName

        const chatData = {
            userName : userName,
            messageContent : messageContent,
            roomName : roomName
        }
        socket.broadcast.to(`${roomName}`).emit('updateChat',JSON.stringify(chatData)) 
    })

    socket.on('typing',function(roomNumber){ 
        console.log('typing triggered')
        socket.broadcast.to(`${roomNumber}`).emit('typing')
    })

    socket.on('stopTyping',function(roomNumber){ 
        console.log('stopTyping triggered')
        socket.broadcast.to(`${roomNumber}`).emit('stopTyping')
    })

    socket.on('disconnect', function () {
        console.log("One of sockets disconnected from our server.")
    });
})

module.exports = server; 