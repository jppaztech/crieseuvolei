(function attachTournamentEngine(global) {
  'use strict';

  const TEAM_COLORS = ['#236b4d', '#b44432', '#315b99', '#9a6512', '#70478d', '#147a82', '#8b4d28', '#57752b'];

  function balanceTeams(players, teamNames) {
    if (!Array.isArray(players) || !Array.isArray(teamNames) || teamNames.length < 2) {
      throw new Error('São necessários jogadores e pelo menos dois times.');
    }
    const teams = teamNames.map((name, index) => ({
      name: String(name || `Time ${index + 1}`).trim() || `Time ${index + 1}`,
      color: TEAM_COLORS[index % TEAM_COLORS.length],
      members: []
    }));
    const totals = teams.map(() => 0);
    [...players]
      .map((player) => ({
        name: String(player.name || '').trim(),
        skill: Math.max(1, Math.min(5, Number(player.skill) || 3))
      }))
      .sort((a, b) => b.skill - a.skill)
      .forEach((player) => {
        const target = teams
          .map((team, index) => ({ index, count: team.members.length, total: totals[index] }))
          .sort((a, b) => a.count - b.count || a.total - b.total || a.index - b.index)[0].index;
        teams[target].members.push(player);
        totals[target] += player.skill;
      });
    return teams;
  }

  function createRoundRobinSchedule(teamCount, roundCount) {
    if (!Number.isInteger(teamCount) || teamCount < 2 || !Number.isInteger(roundCount) || roundCount < 1) {
      throw new Error('A quantidade de times e rodadas é inválida.');
    }
    const rotation = Array.from({ length: teamCount }, (_, index) => index);
    if (rotation.length % 2) rotation.push(null);
    const matches = [];
    for (let round = 1; round <= roundCount; round += 1) {
      let order = 1;
      for (let index = 0; index < rotation.length / 2; index += 1) {
        const a = rotation[index];
        const b = rotation[rotation.length - 1 - index];
        if (a !== null && b !== null) {
          matches.push({ round, order: order++, a, b, scoreA: null, scoreB: null, status: 'pending' });
        }
      }
      const fixed = rotation.shift();
      const last = rotation.pop();
      rotation.unshift(fixed);
      rotation.splice(1, 0, last);
    }
    return matches;
  }

  function calculateStandings(teams, schedule) {
    const stats = teams.map(() => ({ played: 0, wins: 0, losses: 0, pointsFor: 0, pointsAgainst: 0 }));
    schedule.forEach((match) => {
      if (!validateScore(match.scoreA, match.scoreB)) return;
      const a = stats[match.a];
      const b = stats[match.b];
      if (!a || !b) return;
      a.played += 1;
      b.played += 1;
      a.pointsFor += match.scoreA;
      a.pointsAgainst += match.scoreB;
      b.pointsFor += match.scoreB;
      b.pointsAgainst += match.scoreA;
      if (match.scoreA > match.scoreB) {
        a.wins += 1;
        b.losses += 1;
      } else if (match.scoreB > match.scoreA) {
        b.wins += 1;
        a.losses += 1;
      }
    });
    return teams.map((team, index) => ({
      ...team,
      index,
      ...stats[index],
      pointDifference: stats[index].pointsFor - stats[index].pointsAgainst,
      winRate: stats[index].played ? Math.round((stats[index].wins / stats[index].played) * 100) : 0
    })).sort((a, b) =>
      (b.wins - a.wins) ||
      (b.pointDifference - a.pointDifference) ||
      (b.pointsFor - a.pointsFor) ||
      a.name.localeCompare(b.name)
    );
  }

  function createSemifinals(standings) {
    if (!Array.isArray(standings) || standings.length < 4) {
      throw new Error('São necessários pelo menos quatro times para as semifinais.');
    }
    return [
      { id: 'semi-1', label: 'Semifinal 1', round: 'semifinals', a: standings[0].index, b: standings[3].index, scoreA: null, scoreB: null, status: 'pending' },
      { id: 'semi-2', label: 'Semifinal 2', round: 'semifinals', a: standings[1].index, b: standings[2].index, scoreA: null, scoreB: null, status: 'pending' }
    ];
  }

  function createPlacementMatches(semifinals) {
    if (semifinals.length !== 2 || semifinals.some((match) => match.status !== 'done' || match.scoreA === match.scoreB)) {
      throw new Error('Finalize as duas semifinais antes de montar a final.');
    }
    const winners = semifinals.map((match) => match.scoreA > match.scoreB ? match.a : match.b);
    const losers = semifinals.map((match) => match.scoreA > match.scoreB ? match.b : match.a);
    return [
      { id: 'third-place', label: 'Disputa de 3º lugar', round: 'finals', a: losers[0], b: losers[1], scoreA: null, scoreB: null, status: 'pending' },
      { id: 'final', label: 'Final', round: 'finals', a: winners[0], b: winners[1], scoreA: null, scoreB: null, status: 'pending' }
    ];
  }

  function getPodium(playoffs, standings) {
    const final = playoffs.find((match) => match.id === 'final');
    const thirdPlace = playoffs.find((match) => match.id === 'third-place');
    if (!final && !thirdPlace) return standings.map((team, index) => ({ place: index + 1, team }));
    if (!final || final.status !== 'done' || !thirdPlace || thirdPlace.status !== 'done') return [];
    const placements = [
      final.scoreA > final.scoreB ? final.a : final.b,
      final.scoreA > final.scoreB ? final.b : final.a,
      thirdPlace.scoreA > thirdPlace.scoreB ? thirdPlace.a : thirdPlace.b,
      thirdPlace.scoreA > thirdPlace.scoreB ? thirdPlace.b : thirdPlace.a
    ];
    const placed = new Set(placements);
    return [
      ...placements.map((teamIndex, index) => ({ place: index + 1, team: standings.find((team) => team.index === teamIndex) })),
      ...standings.filter((team) => !placed.has(team.index)).map((team, index) => ({ place: index + 5, team }))
    ];
  }

  function normalize(gameData, tournamentStatus = 'draft') {
    const data = gameData && typeof gameData === 'object' ? gameData : {};
    const schedule = Array.isArray(data.schedule) ? data.schedule.map((match) => ({
      ...match,
      status: validateScore(match.scoreA, match.scoreB) ? 'done' : 'pending'
    })) : [];
    let phase = data.phase;
    if (!phase) {
      if (tournamentStatus === 'finished') phase = 'podium';
      else if (schedule.length) phase = 'groups';
      else if (Array.isArray(data.playersList) && data.playersList.length) phase = 'players';
      else phase = 'setup';
    }
    return {
      players: Number(data.players) || 0,
      teams: Number(data.teams) || 0,
      rounds: Number(data.rounds) || 0,
      playersList: Array.isArray(data.playersList) ? data.playersList : [],
      teamsList: Array.isArray(data.teamsList) ? data.teamsList : [],
      schedule,
      currentIndex: Number(data.currentIndex) || 0,
      phase,
      semifinals: Array.isArray(data.semifinals) ? data.semifinals : [],
      playoffs: Array.isArray(data.playoffs) ? data.playoffs : [],
      ...(data.exportData && typeof data.exportData === 'object' ? { exportData: data.exportData } : {})
    };
  }

  function validateScore(scoreA, scoreB) {
    return Number.isInteger(scoreA) && Number.isInteger(scoreB) && scoreA >= 0 && scoreB >= 0 && scoreA !== scoreB;
  }

  global.CrieSeuVoleiTournament = Object.freeze({
    balanceTeams,
    calculateStandings,
    createPlacementMatches,
    createRoundRobinSchedule,
    createSemifinals,
    getPodium,
    normalize,
    validateScore
  });
})(window);
