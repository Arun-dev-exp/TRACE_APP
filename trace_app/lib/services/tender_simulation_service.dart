import 'dart:math';

class Bidder {
  final String id;
  final String name;
  final double bidAmountCr;
  final double pastDeliverySuccessRate; // 0.0 to 1.0
  final int ongoingProjects;
  final String marketSentiment; // 'Negative', 'Neutral', 'Positive'
  final List<String> backgroundAlerts;

  double score = 0.0;
  bool rejected = false;
  String rejectionReason = '';

  Bidder({
    required this.id,
    required this.name,
    required this.bidAmountCr,
    required this.pastDeliverySuccessRate,
    required this.ongoingProjects,
    required this.marketSentiment,
    this.backgroundAlerts = const [],
  });
}

class TenderProject {
  final String title;
  final String description;
  final double benchmarkLowCr;
  final double benchmarkHighCr;

  TenderProject({
    required this.title,
    required this.description,
    required this.benchmarkLowCr,
    required this.benchmarkHighCr,
  });
}

class TenderSimulationService {
  final TenderProject project = TenderProject(
    title: '4-Lane Highway Expansion, Sector 7',
    description: '12km road expansion including 2 flyovers and drainage systems.',
    benchmarkLowCr: 45.5,
    benchmarkHighCr: 52.0,
  );

  List<Bidder> getBidders() {
    return [
      Bidder(
        id: 'B1',
        name: 'Apex Infra & Build',
        bidAmountCr: 32.0, // Low-ball
        pastDeliverySuccessRate: 0.45,
        ongoingProjects: 8,
        marketSentiment: 'Negative',
        backgroundAlerts: ['Sub-standard material report in 2023', 'Delay penalties active'],
      ),
      Bidder(
        id: 'B2',
        name: 'Global Roadways Ltd',
        bidAmountCr: 78.5, // Over-priced
        pastDeliverySuccessRate: 0.92,
        ongoingProjects: 2,
        marketSentiment: 'Positive',
        backgroundAlerts: [],
      ),
      Bidder(
        id: 'B3',
        name: 'Prime State Contractors',
        bidAmountCr: 48.2, // Optimal
        pastDeliverySuccessRate: 0.88,
        ongoingProjects: 3,
        marketSentiment: 'Positive',
        backgroundAlerts: ['Minor delay in 2021 (Covid)'],
      ),
      Bidder(
        id: 'B4',
        name: 'Rapid Build Co.',
        bidAmountCr: 51.5, // Okay but slightly high
        pastDeliverySuccessRate: 0.70,
        ongoingProjects: 5,
        marketSentiment: 'Neutral',
        backgroundAlerts: [],
      ),
    ];
  }

  void evaluateBidders(List<Bidder> bidders) {
    for (var bidder in bidders) {
      // 1. Check Bid Range
      if (bidder.bidAmountCr < project.benchmarkLowCr * 0.8) {
        bidder.rejected = true;
        bidder.rejectionReason = 'Bid critically below benchmark (Risk of ghosting or poor materials)';
        continue;
      }
      if (bidder.bidAmountCr > project.benchmarkHighCr * 1.3) {
        bidder.rejected = true;
        bidder.rejectionReason = 'Bid exceptionally high (Risk of fund siphoning)';
        continue;
      }

      // 2. Check Past Delivery
      if (bidder.pastDeliverySuccessRate < 0.6) {
        bidder.rejected = true;
        bidder.rejectionReason = 'Poor track record (<60% success)';
        continue;
      }

      // 3. Check Sentiment / Alerts
      if (bidder.marketSentiment == 'Negative' || bidder.backgroundAlerts.length > 1) {
        bidder.rejected = true;
        bidder.rejectionReason = 'High risk flagged by market intelligence';
        continue;
      }

      // Calculate Score (Higher is better)
      // Base score 100
      double baseScore = 100;
      
      // Penalty for being far from benchmark midpoint
      double midpoint = (project.benchmarkLowCr + project.benchmarkHighCr) / 2;
      double diffPct = (bidder.bidAmountCr - midpoint).abs() / midpoint;
      baseScore -= (diffPct * 50); // Lose up to 50 points based on deviation

      // Bonus for success rate
      baseScore += (bidder.pastDeliverySuccessRate * 30);

      // Penalty for ongoing projects (too many = stretched thin)
      if (bidder.ongoingProjects > 4) {
        baseScore -= (bidder.ongoingProjects * 2);
      }

      bidder.score = max(0, baseScore);
    }
  }

  Bidder? getWinner(List<Bidder> bidders) {
    final validBidders = bidders.where((b) => !b.rejected).toList();
    if (validBidders.isEmpty) return null;
    validBidders.sort((a, b) => b.score.compareTo(a.score));
    return validBidders.first;
  }
}
