// One-line system info (battery + CPU), under the clock — Moonfly palette
export const command = `echo "$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)|$(top -l 1 -n 0 | awk '/CPU usage/ {printf "%.0f%%", $3 + $5}')"`;

export const refreshFrequency = 30000; // 30s

export const className = `
  top: 100px;
  right: 28px;
  text-align: right;
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 10px;
  letter-spacing: 1px;
  color: #949494;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.6);
`;

export const render = ({ output }) => {
  const [bat, cpu] = (output || "|").trim().split("|");
  return (
    <div>
      <span style={{ color: "#626262" }}>bat </span>
      {bat}
      <span style={{ color: "#626262" }}>  cpu </span>
      {cpu}
    </div>
  );
};
