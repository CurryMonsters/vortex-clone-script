# vortex-clone-script

Clones all the Vortex repos into `~/code/ros2_ws/src` in one go.

```bash
git clone https://github.com/CurryMonsters/vortex-clone-script.git
cd vortex-clone-script
./install.sh
```

| Option | Effect |
|---|---|
| *(none)* | clones over HTTPS into `~/code/ros2_ws/src` |
| `--ssh` | clone over SSH on port 443 instead of HTTPS |
| `--ws=PATH` | use another ROS 2 workspace (default `~/code/ros2_ws`) |

Repos that already exist are skipped, so the script is safe to run again.
