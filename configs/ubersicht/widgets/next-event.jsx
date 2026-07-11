// Next calendar event of the day (icalBuddy) — Moonfly palette
export const command = `PATH="/etc/profiles/per-user/gauthierseyzeriat/bin:/opt/homebrew/bin:$PATH" icalBuddy -n -nc -li 1 -b '' -ps '| · |' -iep 'datetime,title' -po 'datetime,title' -tf '%H:%M' -df '' eventsToday 2>/dev/null || echo ""`;

export const refreshFrequency = 300000; // 5 min

export const className = `
  top: 148px;
  right: 28px;
  text-align: right;
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 10px;
  letter-spacing: 1px;
  color: #949494;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.6);
`;

export const render = ({ output }) => {
  const event = (output || "").trim();
  if (!event) return <div />;
  return (
    <div>
      <span style={{ color: "#626262" }}>next </span>
      {event}
    </div>
  );
};
