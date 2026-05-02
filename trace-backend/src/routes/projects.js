const router = require('express').Router();
const supabase = require('../models/db');

// GET /api/projects/:districtId
router.get('/:districtId', async (req, res) => {
  const { districtId } = req.params;

  try {
    const { data: projects, error } = await supabase
      .from('projects')
      .select('*, districts(name)')
      .eq('district_id', districtId)
      .order('risk_score', { ascending: false });

    if (error) throw error;

    const result = projects.map(p => ({
      id: p.id,
      name: p.name,
      contractor: p.contractor_id || 'State PWD',
      milestone: p.status,
      lat: p.gps_lat,
      lng: p.gps_lng,
      districtId: p.district_id,
      districtName: p.districts?.name || 'Unknown',
      flagged: p.status === 'flagged',
      riskScore: p.risk_score
    }));

    res.json(result);
  } catch (err) {
    console.error('GET /api/projects/:districtId error:', err.message);
    res.status(500).json({ error: 'Failed to fetch projects' });
  }
});

module.exports = router;
