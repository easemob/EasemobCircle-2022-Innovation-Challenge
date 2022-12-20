import AgoraRTC from "agora-rtc-sdk-ng";

export const useWebRtc = () => {
    const client = AgoraRTC.createClient({
        mode: "rtc",
        codec: "vp8"
    });

    client.on("user-published", async (user, mediaType) => {
        await client.subscribe(user, mediaType);
        if (mediaType === "video") {
            const player = user.videoTrack;
            player.play("remote-player");
        }
        if (mediaType === "audio") {
            const player = user.audioTrack;
            player.play();
        }
    });

    client.on("user-unpublished", (user) => {
        // setRemoteStreamList((prev) => prev.filter((item) => item.getId() !== user.uid));
    });

    client.on("user-left", (user) => {
        // setRemoteStreamList((prev) => prev.filter((item) => item.getId() !== user.uid));
    })

    client.on("user-joined", (user) => {
        // setRemoteStreamList((prev) => [...prev, user]);
    })

    client.on("user-left", (user) => {
        // setRemoteStreamList((prev) => prev.filter((item) => item.getId() !== user.uid));
    })
}