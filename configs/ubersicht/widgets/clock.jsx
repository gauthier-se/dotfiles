// Discreet clock + date, top right — Moonfly palette
export const command = `LC_TIME=fr_FR.UTF-8 date +"%H:%M|%a %d %b"`;

export const refreshFrequency = 10000; // 10s

export const className = `
  top: 44px;
  right: 28px;
  text-align: right;
  font-family: "JetBrainsMono Nerd Font", monospace;
  color: #bdbdbd;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.6);
`;

export const render = ({ output }) => {
  const [time, date] = (output || "|").trim().split("|");
  return (
    <div>
      <div style={{ fontSize: "22px", fontWeight: 300, letterSpacing: "2px" }}>{time}</div>
      <div style={{ fontSize: "11px", color: "#949494", marginTop: "2px", letterSpacing: "1px" }}>{date}</div>
    </div>
  );
};
