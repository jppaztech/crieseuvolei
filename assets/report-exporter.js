(function attachReportExporter(global) {
  'use strict';

  function escapeHtml(value) {
    return String(value ?? '').replace(/[&<>"']/g, (char) => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[char]);
  }

  function createSheet(title, tournamentName, sections) {
    return `<article class="export-sheet">
      <header><p>CrieSeuVôlei</p><h1>${escapeHtml(title)}</h1><h2>${escapeHtml(tournamentName)}</h2></header>
      ${sections.join('')}
    </article>`;
  }

  function teamRosterHtml(teams, labels) {
    return `<section><h2>${escapeHtml(labels.teams)}</h2>${teams.map((team) => `
      <div class="export-team">
        <h3 style="--team-color:${escapeHtml(team.color || '#236b4d')}">${escapeHtml(team.name)}</h3>
        <ul>${(team.members || []).map((player) => `<li>${escapeHtml(player.name)} <span>${escapeHtml(`${labels.skill} ${player.skill || 3}/5`)}</span></li>`).join('')}</ul>
      </div>`).join('')}</section>`;
  }

  function matchRowsHtml(matches, teams, labels) {
    const rounds = new Map();
    matches.forEach((match) => {
      const group = match.label || `${labels.round} ${match.round}`;
      if (!rounds.has(group)) rounds.set(group, []);
      rounds.get(group).push(match);
    });
    return [...rounds.entries()].map(([label, group]) => `<section>
      <h2>${escapeHtml(label)}</h2>
      ${group.map((match) => {
        const a = teams[match.a];
        const b = teams[match.b];
        const playersA = (a?.members || []).map((player) => player.name).join(', ');
        const playersB = (b?.members || []).map((player) => player.name).join(', ');
        const score = Number.isInteger(match.scoreA) && Number.isInteger(match.scoreB) &&
          match.scoreA >= 0 && match.scoreB >= 0 && match.scoreA !== match.scoreB
          ? `${match.scoreA} : ${match.scoreB}`
          : '– : –';
        return `<div class="export-match">
          <div><strong>${escapeHtml(a?.name || labels.team)}</strong><small>${escapeHtml(playersA)}</small></div>
          <b>${escapeHtml(score)}</b>
          <div><strong>${escapeHtml(b?.name || labels.team)}</strong><small>${escapeHtml(playersB)}</small></div>
        </div>`;
      }).join('')}
    </section>`).join('');
  }

  function renderHtml(title, tournamentName, sections) {
    return `<style>
      .export-sheet{width:760px;max-width:100%;padding:32px;background:#fff;color:#17251f;font:15px/1.45 Arial,sans-serif}
      .export-sheet>header{padding:0 0 18px;border-bottom:2px solid #236b4d;margin-bottom:20px}
      .export-sheet>header p{margin:0 0 4px;color:#236b4d;font-weight:700}
      .export-sheet h1{margin:0;font-size:28px;line-height:1.15}
      .export-sheet>header h2{margin:5px 0 0;color:#53665b;font-size:17px}
      .export-sheet section{margin:0 0 22px;break-inside:avoid}
      .export-sheet section>h2{padding-bottom:5px;border-bottom:1px solid #d8e2da;font-size:18px}
      .export-team{padding:9px 12px;margin:8px 0;border:1px solid #d8e2da;border-radius:7px;break-inside:avoid}
      .export-team h3{margin:0;color:var(--team-color);font-size:16px}
      .export-team ul{margin:6px 0 0;padding-left:20px}
      .export-team li{padding:2px 0}
      .export-team li span{color:#53665b}
      .export-match{display:grid;grid-template-columns:minmax(0,1fr) auto minmax(0,1fr);align-items:center;gap:12px;padding:10px 4px;border-bottom:1px solid #d8e2da;break-inside:avoid}
      .export-match>div:last-child{text-align:right}
      .export-match small{display:block;color:#53665b;font-size:12px}
      .export-match>b{font-size:17px;white-space:nowrap}
      .export-standing{display:grid;grid-template-columns:36px minmax(0,1fr) repeat(4,52px);gap:8px;padding:7px 4px;border-bottom:1px solid #d8e2da}
      .export-standing-header{font-weight:700;color:#174d39}
      .export-podium{padding:12px;margin:8px 0;background:#eaf0eb;border-radius:6px}
      .export-podium:first-child{background:#fff2cc}
      .export-podium strong,.export-podium span{display:block}
      .export-podium span{color:#53665b}
      @media print{.export-sheet{width:auto;padding:0}.export-sheet section{break-inside:auto}}
    </style>${createSheet(title, tournamentName, sections)}`;
  }

  async function exportFile({ html, format, filename, labels }) {
    const host = document.createElement('div');
    host.className = 'export-host';
    host.setAttribute('aria-label', labels.generating);
    host.innerHTML = html;
    document.body.append(host);
    try {
      if (format === 'jpeg') {
        if (typeof global.html2canvas !== 'function') throw new Error('O serviço de exportação de imagem não carregou.');
        const canvas = await global.html2canvas(host.querySelector('.export-sheet'), {
          scale: 2,
          backgroundColor: '#ffffff',
          useCORS: true
        });
        const link = document.createElement('a');
        link.download = filename;
        link.href = canvas.toDataURL('image/jpeg', 0.94);
        link.click();
        return;
      }
      if (typeof global.html2pdf !== 'function') throw new Error('O serviço de exportação de PDF não carregou.');
      await global.html2pdf().set({
        margin: [10, 10, 10, 10],
        filename,
        image: { type: 'jpeg', quality: 0.96 },
        html2canvas: { scale: 2, useCORS: true, backgroundColor: '#ffffff' },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
        pagebreak: { mode: ['css', 'legacy'] }
      }).from(host.querySelector('.export-sheet')).save();
    } finally {
      host.remove();
    }
  }

  global.CrieSeuVoleiReports = Object.freeze({
    exportFile,
    matchRowsHtml,
    renderHtml,
    teamRosterHtml
  });
})(window);
