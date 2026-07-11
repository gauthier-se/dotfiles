// One-line weather (wttr.in, geolocated by IP) — Moonfly palette
export const command = `curl -s --max-time 10 "wttr.in/?format=%c+%t" 2>/dev/null | sed 's/+//' || echo ""`;

export const refreshFrequency = 1800000; // 30 min

export const className = `
  top: 124px;
  right: 28px;
  text-align: right;
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 10px;
  letter-spacing: 1px;
  color: #949494;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.6);
`;

export const render = ({ output }) => <div>{(output || "").trim()}</div>;
