const std = @import("std");
const rl = @import("raylib");

const WIDTH: i32 = 800;
const HEIGHT: i32 = 500;
const FONT_SIZE: i32 = 20;
const PADDLE_W: i32 = 10;
const PADDLE_H: i32 = 100;
const VELOCITY: i32 = 10;
const RADIUS: i32 = 10;

const dir = enum {
    LEFT_MID,
    LEFT_UP,
    LEFT_DOWN,
    RIGHT_MID,
    RIGHT_UP,
    RIGHT_DOWN,
};

const game = struct {
    player1: Player,
    player2: Player,
    ball: Ball,

    pub fn updateState(self: *@This()) void {
        self.player1.updateState();
        self.player2.updateState();
        _ = self.checkCollisition();
        self.checkLimits();
        self.ball.updateState();
    }

    fn checkCollisition(self: *@This()) f32 {
        if (self.ball.pos.x == self.player2.pos.x and
            self.ball.pos.y >= self.player2.pos.y and self.ball.pos.y <= self.player2.pos.y + PADDLE_H)
        {
            const theta = std.math.pi * self.ball.pos.y / 2 * 60;
            const angle = std.math.tan(theta);
            if (self.ball.pos.y >= self.player2.pos.y and
                self.ball.pos.y <= self.player2.pos.y + @divFloor(PADDLE_H, 2))
            {
                self.ball.direction = .LEFT_UP;
                self.ball.dt = angle;
                return angle;
            }
            if (self.ball.pos.y >= self.player2.pos.y + @divFloor(PADDLE_H, 2) + 1 and
                self.ball.pos.y <= self.player2.pos.y + PADDLE_H)
            {
                self.ball.direction = .LEFT_DOWN;
                self.ball.dt = angle * -1;
                return angle;
            }
            self.ball.direction = dir.LEFT_MID;
            self.ball.dt = 0;
        }
        if (self.ball.pos.x == self.player1.pos.x + PADDLE_W and
            self.ball.pos.y >= self.player1.pos.y and
            self.ball.pos.y <= self.player1.pos.y + PADDLE_H)
        {
            const theta = std.math.pi * self.ball.pos.y / 2 * 60;
            const angle = std.math.tan(theta);
            if (self.ball.pos.y >= self.player1.pos.y and
                self.ball.pos.y <= self.player1.pos.y + @divFloor(PADDLE_H, 2))
            {
                self.ball.direction = .RIGHT_UP;
                self.ball.dt = angle;
                return angle;
            }
            if (self.ball.pos.y >= self.player1.pos.y + @divFloor(PADDLE_H, 2) + 1 and
                self.ball.pos.y <= self.player1.pos.y + PADDLE_H)
            {
                self.ball.direction = .RIGHT_DOWN;
                self.ball.dt = angle * -1;
                return angle;
            }
            self.ball.direction = dir.RIGHT_MID;
            self.ball.dt = 0;
        }
        if (self.ball.pos.y <= 0) {
            switch (self.ball.direction) {
                .RIGHT_UP => {
                    self.ball.direction = .RIGHT_DOWN;
                    self.ball.dt = -self.ball.dt;
                },
                .RIGHT_DOWN => {
                    self.ball.direction = .RIGHT_DOWN;
                    self.ball.dt = -self.ball.dt;
                },
                .LEFT_UP => {
                    self.ball.direction = .LEFT_DOWN;
                    self.ball.dt = -self.ball.dt;
                },
                .LEFT_DOWN => {
                    self.ball.direction = .LEFT_DOWN;
                    self.ball.dt = -self.ball.dt;
                },
                else => self.ball.dt = self.ball.dt,
            }
        }
        if (self.ball.pos.y >= HEIGHT) {
            //const theta = std.math.pi * self.ball.pos.y / 2 * 60;
            //const angle = std.math.tan(theta);
            switch (self.ball.direction) {
                .RIGHT_DOWN => {
                    self.ball.direction = .RIGHT_UP;
                    self.ball.dt = -self.ball.dt;
                },
                .RIGHT_UP => {
                    self.ball.direction = .RIGHT_UP;
                    self.ball.dt = -self.ball.dt;
                },
                .LEFT_DOWN => {
                    self.ball.direction = .LEFT_UP;
                    self.ball.dt = -self.ball.dt;
                },
                .LEFT_UP => {
                    self.ball.direction = .LEFT_UP;
                    self.ball.dt = -self.ball.dt;
                },
                else => self.ball.dt = self.ball.dt,
            }
        }
        return self.ball.dt;
    }

    fn checkLimits(self: *@This()) void {
        if (self.ball.pos.x >= WIDTH) {
            self.ball.pos = rl.Vector2.init(WIDTH / 2, HEIGHT / 2);
            self.ball.dt = 0;
            self.player1.points = self.player1.points + 1;
        }
        if (self.ball.pos.x <= 0) {
            self.ball.pos = rl.Vector2.init(WIDTH / 2, HEIGHT / 2);
            self.ball.dt = 0;
            self.player2.points = self.player2.points + 1;
        }
    }
};

var g: game = undefined;

const Ball = struct {
    pos: rl.Vector2 = rl.Vector2.init(WIDTH / 2, HEIGHT / 2),
    color: rl.Color = rl.Color.white,
    radius: i32 = RADIUS,
    direction: dir,
    dt: f32,

    pub fn ballInit(pos: rl.Vector2, rad: i32, color: rl.Color) @This() {
        return .{
            .pos = pos,
            .color = color,
            .radius = rad,
            .direction = dir.LEFT_MID,
            .dt = 0,
        };
    }

    pub fn drawBall(ball: *@This()) void {
        rl.drawCircle(
            @intFromFloat(ball.pos.x),
            @intFromFloat(ball.pos.y),
            @floatFromInt(ball.radius),
            ball.color,
        );
    }

    pub fn updateState(ball: *@This()) void {
        switch (ball.direction) {
            .RIGHT_UP => {
                ball.pos.x = ball.pos.x + VELOCITY;
                ball.pos.y = ball.pos.y + ball.dt;
            },
            .RIGHT_MID => {
                ball.pos.x = ball.pos.x + VELOCITY;
                ball.pos.y = ball.pos.y + ball.dt;
            },
            .RIGHT_DOWN => {
                ball.pos.x = ball.pos.x + VELOCITY;
                ball.pos.y = ball.pos.y + ball.dt;
            },
            .LEFT_UP => {
                ball.pos.x = ball.pos.x - VELOCITY;
                ball.pos.y = ball.pos.y + ball.dt;
            },
            .LEFT_MID => {
                ball.pos.x = ball.pos.x - VELOCITY;
                ball.pos.y = ball.pos.y + ball.dt;
            },
            .LEFT_DOWN => {
                ball.pos.x = ball.pos.x - VELOCITY;
                ball.pos.y = ball.pos.y + ball.dt;
            },
        }
    }
};

const Player = struct {
    name: [:0]const u8,
    pos: rl.Vector2,
    rec: rl.Rectangle,
    points: i32,
    upKey: rl.KeyboardKey,
    downKey: rl.KeyboardKey,

    pub fn createPlayer(name: [:0]const u8, pos: rl.Vector2, points: i32, upKey: rl.KeyboardKey, downKey: rl.KeyboardKey) @This() {
        return .{
            .name = name,
            .pos = pos,
            .points = points,
            .rec = rl.Rectangle.init(pos.x, pos.y, PADDLE_W, PADDLE_H),
            .upKey = upKey,
            .downKey = downKey,
        };
    }
    pub fn updateState(self: *@This()) void {
        if (rl.isKeyDown(self.downKey)) {
            if (self.pos.y + self.rec.height + 5 > HEIGHT) {
                self.pos.y = HEIGHT - self.rec.height;
                return;
            }
            self.pos.y = self.pos.y + VELOCITY;
        }
        if (rl.isKeyDown(self.upKey)) {
            if (self.pos.y - 5 < 0) {
                self.pos.y = 0;
                return;
            }
            self.pos.y = self.pos.y - VELOCITY;
        }
    }

    pub fn drawPlayer(player: *@This()) void {
        rl.drawRectangle(
            @intFromFloat(player.pos.x),
            @intFromFloat(player.pos.y),
            @intFromFloat(player.rec.width),
            @intFromFloat(player.rec.height),
            rl.Color.white,
        );
    }

    pub fn drawName(self: *@This(), x: i32, y: i32) void {
        rl.drawText(
            self.name,
            x,
            y,
            20,
            rl.Color.gray,
        );
    }

    pub fn drawScore(self: *@This(), x: i32, y: i32) !void {
        var score: [3:0]u8 = undefined;
        const str = try std.fmt.bufPrintZ(&score, "{}", .{self.points});
        //std.debug.print("{}\n", .{rl.measureText(str, 30)});
        rl.drawText(
            str,
            x,
            y,
            30,
            rl.Color.gray,
        );
    }
};

fn drawDottedLine(x: i32, y: *i32) void {
    for (0..HEIGHT) |_| {
        rl.drawPixel(x, y.*, rl.Color.gray);
        y.* = y.* + 3;
    }
}

fn render() !void {
    g.player1.drawName(10, 20);
    g.player2.drawName(WIDTH - (rl.measureText(g.player2.name, 20) + 10), 20);

    try g.player1.drawScore(WIDTH / 2 - 34, HEIGHT - 35);
    try g.player2.drawScore(WIDTH / 2 + 20, HEIGHT - 35);

    var begin_line: i32 = 0;
    drawDottedLine(WIDTH / 2, &begin_line);

    g.player1.drawPlayer();
    g.player2.drawPlayer();
    g.ball.drawBall();
}

pub fn main() !void {
    rl.initWindow(WIDTH, HEIGHT, "Pong!");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    g.player1 = Player.createPlayer(
        "Player 1",
        rl.Vector2.init(60, (HEIGHT / 2) - 30),
        0,
        .key_w,
        .key_s,
    );

    g.player2 = Player.createPlayer(
        "Player 2",
        rl.Vector2.init(WIDTH - 70, (HEIGHT / 2) - 30),
        0,
        .key_k,
        .key_j,
    );

    g.ball = Ball.ballInit(
        rl.Vector2.init(WIDTH / 2, HEIGHT / 2),
        RADIUS,
        rl.Color.white,
    );

    std.debug.print("Let him cook", .{});
    const beginText = "Ready, Set, Go!";

    while (!rl.windowShouldClose()) {
        const time = rl.getTime();
        rl.beginDrawing();
        defer rl.endDrawing();

        if (time < 1.5) {
            rl.drawText(
                beginText,
                (WIDTH / 2) - @divExact(rl.measureText(beginText, FONT_SIZE), 2),
                HEIGHT / 2,
                FONT_SIZE,
                rl.Color.white,
            );
        }

        if (time > 1.5) {
            g.updateState();
            try render();
        }

        rl.clearBackground(
            rl.Color.black,
        );
    }
}
