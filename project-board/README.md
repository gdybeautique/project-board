# Project Board 🚀

An agile project management system on the blockchain where teams can create user stories, track sprint progress, and earn sprint trophies as NFT achievements.

## Overview

Project Board brings agile methodology to the blockchain, creating an immutable record of sprint achievements and team velocity. Perfect for distributed teams who want transparent, verifiable project management with gamified rewards for productivity.

## Features

### 📋 Core Functionality
- **Create Stories**: Add user stories with acceptance criteria
- **Move to Done**: Complete stories and update sprint progress
- **Remove from Backlog**: Clean up outdated stories
- **Refine Stories**: Update story details during grooming sessions

### 🏆 Sprint Trophies (NFT Rewards)
Earn team recognition through NFT trophies:
- **Sprint Rookie** - Complete your first story
- **Sprint Veteran** - Complete 10 stories
- **Sprint Hero** - Complete 50 stories
- **Sprint Legend** - Complete 100 stories

### 📊 Velocity Tracking
- Total stories created
- Stories completed
- Backlog size
- Sprint achievements

## Smart Contract Functions

### Public Functions

#### `create-story`
```clarity
(create-story (story-title (string-utf8 256)) (acceptance-criteria (string-utf8 1024)))
```
Add a new user story to the backlog with title and acceptance criteria.

#### `move-to-done`
```clarity
(move-to-done (story-id uint))
```
Mark a story as done and check for sprint trophy eligibility.

#### `remove-from-backlog`
```clarity
(remove-from-backlog (story-id uint))
```
Remove an incomplete story from the backlog.

#### `refine-story`
```clarity
(refine-story (story-id uint) (story-title (string-utf8 256)) (acceptance-criteria (string-utf8 1024)))
```
Update story details during refinement.

### Read-Only Functions

#### `view-story`
```clarity
(view-story (story-id uint) (team-member principal))
```
View details of a specific user story.

#### `get-velocity`
```clarity
(get-velocity (team-member principal))
```
Check a team member's velocity metrics.

#### `has-sprint-trophy`
```clarity
(has-sprint-trophy (team-member principal) (trophy-type (string-ascii 50)))
```
Verify if a team member has earned a specific sprint trophy.

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for team member identification

### Installation
```bash
git clone https://github.com/your-repo/project-board
cd project-board
clarinet integrate
```

### Testing
```bash
clarinet test
```

### Deployment
```bash
clarinet deployments generate --mainnet
clarinet deployments apply -p deployments/mainnet.plan.yaml
```

## Usage Example

```clarity
;; Create a new user story
(contract-call? .project-board create-story 
    u"As a user, I want to login with my wallet" 
    u"Given I have a wallet, when I click login, then I should be authenticated")

;; Move story to done
(contract-call? .project-board move-to-done u0)

;; Check team velocity
(contract-call? .project-board get-velocity tx-sender)
```

## Architecture

### Agile Data Structure
- **User Stories Map**: Stores story details and status
- **Team Velocity Map**: Tracks productivity metrics
- **Sprint Achievements Map**: Records trophy awards

### Scrum Alignment
- Story point tracking
- Sprint-based timestamps
- Team member accountability
- Transparent progress

## Agile Framework

### Story Lifecycle
1. **Create** - Add to product backlog
2. **Refine** - Groom and estimate
3. **Sprint** - Work in progress
4. **Done** - Meet acceptance criteria

### Trophy System
Sprint trophies are automatically minted as NFTs when team members reach productivity milestones. These serve as proof of contribution and can be showcased in professional profiles.

## Agile Ceremonies Support

### Sprint Planning
- Create stories for upcoming sprint
- Set clear acceptance criteria
- Track story points

### Daily Standup
- View active stories
- Check team velocity
- Identify blockers

### Sprint Review
- Demonstrate completed stories
- Celebrate trophy achievements
- Review team metrics

### Sprint Retrospective
- Analyze velocity trends
- Identify improvement areas
- Plan process updates

## Integration Capabilities

### Project Management Tools
```javascript
// JIRA Integration Example
const projectBoard = new ProjectBoardSDK({
  network: 'mainnet',
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.project-board'
});

// Sync story from JIRA
await projectBoard.createStory({
  title: jiraIssue.summary,
  acceptanceCriteria: jiraIssue.description
});

// Update JIRA on completion
await projectBoard.onStoryComplete(storyId, (story) => {
  jiraAPI.transitionIssue(story.externalId, 'Done');
});
```

### Reporting Features
- Velocity charts
- Burndown tracking
- Trophy leaderboards
- Sprint summaries

## Team Features

### Multi-Team Support
- Separate backlogs per team
- Cross-team visibility
- Shared trophy system
- Comparative metrics

### Remote Team Benefits
- Timezone-agnostic tracking
- Transparent progress
- Decentralized accountability
- Global accessibility

## Best Practices

### Story Writing
- Clear, concise titles
- Specific acceptance criteria
- Estimatable scope
- User-focused language

### Sprint Success
- Regular story refinement
- Consistent velocity
- Celebrate achievements
- Continuous improvement

## Contributing

Help us build better agile tools! See our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: [docs.projectboard.dev](https://docs.projectboard.dev)
- Scrum Master Support: [scrum@projectboard.dev](mailto:scrum@projectboard.dev)
- Slack: [Join our workspace](https://projectboard.slack.com)
- Twitter: [@ProjectBoardDAO](https://twitter.com/projectboarddao)