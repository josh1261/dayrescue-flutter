# DayRescue Roadmap

DayRescue is currently a public portfolio MVP.  
The goal of this repository is to show the development process, product thinking, Flutter implementation, GitHub workflow, and deployment experience.

This public version is not the final monetized product.  
If DayRescue moves toward real monetization, the production version should be separated into private repositories.

---

## Current Stage

### Public Portfolio MVP

The current version focuses on:

- Building a working Flutter MVP
- Showing the full user flow
- Managing local state with SharedPreferences
- Adding a reward system
- Preventing repeated RP farming
- Adding mascot-based emotional feedback
- Deploying a live Flutter Web demo with GitHub Pages
- Documenting progress through GitHub commits and README updates

Live Demo:

https://josh1261.github.io/dayrescue-flutter/

---

## Completed Features

### Core App Flow

- Home screen
- Daily input screen
- Task classification flow
- Compressed plan result screen
- Completion check screen
- Result screen
- Mascot shop screen

### Reward System

- RP reward calculation
- Total RP persistence
- Recent result persistence
- Daily task reward limit
- Ad reward limit
- RP farming prevention

### Mascot System

- PNG mascot asset replacement
- Transparent background cleanup
- Default mascot
- Cheer expression
- Success expression
- Comfort expression
- Result-based mascot expression
- Consistent mascot interaction behavior

### Portfolio Setup

- GitHub repository
- README documentation
- Screenshots
- Reward system improvement notes
- Mascot feedback system notes
- GitHub Pages live demo deployment

### Performance Improvement

- Mascot image optimization
- Reduced visual asset size
- Improved web demo responsiveness

---

## Next Improvements

The next goal is to make DayRescue feel more useful in real daily recovery situations.

### 1. Improve Rescue Plan Quality

Planned improvements:

- Make rescue plans more specific and actionable
- Add time-blocked recommendations
- Explain why each task is kept, reduced, delayed, or dropped
- Make the result feel less like a simple checklist and more like a realistic recovery plan

Example direction:

- Must-save task
- Reduced task
- Dropped task
- Recovery break
- Suggested next action

---

### 2. Improve Input UX

Current input flow works as an MVP, but it can feel too form-like.

Planned improvements:

- Make the input flow feel more conversational
- Reduce the number of required fields
- Add example placeholders
- Add quick-select options for common situations
- Make it easier to use when the user is tired or overwhelmed

---

### 3. Improve Result Screen UX

Planned improvements:

- Make the result card easier to read
- Highlight the most important action
- Add clearer feedback text
- Improve visual hierarchy
- Make the mascot feedback more contextual

---

### 4. Improve Mobile Experience

Planned improvements:

- Test on small mobile screens
- Improve scroll behavior
- Check keyboard overlap issues
- Adjust button spacing
- Improve touch comfort
- Review layout on iPhone and Android screens

---

### 5. Improve Performance

Planned improvements:

- Continue reducing image size
- Consider WebP assets if needed
- Check Flutter Web build size
- Improve initial loading experience
- Remove unused assets or code

---

## Monetization Transition Plan

This public repository is for portfolio and learning purposes.

If DayRescue moves toward monetization, the project should be split into public and private versions.

---

## Public Version

Repository:

- dayrescue-flutter

Purpose:

- Portfolio
- Learning record
- MVP demo
- GitHub activity proof
- Public live demo

Allowed in public version:

- Basic UI
- Basic Flutter app structure
- Local storage MVP
- Screenshots
- README
- Public demo
- Non-sensitive learning code

---

## Private Product Version

Possible future repositories:

- dayrescue-product
- dayrescue-backend

Purpose:

- Real monetized product
- User data handling
- AI logic
- Payment logic
- Ad logic
- Production deployment

Should be private:

- AI API keys
- Backend code
- Payment logic
- Ad SDK configuration
- User data logic
- Production prompts
- Business strategy
- Monetization experiments
- Sensitive service logic

---

## When to Switch to Private Development

DayRescue should move to a private production version if any of the following are added:

- Real AI API integration
- Login or user accounts
- User data storage on a server
- Payment system
- Real ad SDK
- Subscription features
- Production backend
- Real user analytics
- Commercial launch plan

At that stage, the public repository should remain as a portfolio MVP, and the actual product should be developed separately in private.

---

## Future Product Directions

Possible directions:

### 1. AI-Assisted Plan Compression

Use AI to analyze the user's remaining tasks, time, condition, and priority.

Potential features:

- Natural language input
- Automatic task reduction
- Explanation for each decision
- Personalized recovery plan

### 2. Student Productivity Version

Focus on students who fail to follow their study plans.

Potential features:

- Study rescue mode
- Exam period mode
- Assignment rescue mode
- Daily study recovery plan

### 3. Habit and Recovery Companion

Make DayRescue less like a strict task manager and more like a supportive recovery companion.

Potential features:

- Mascot dialogue
- Recovery streak
- Gentle feedback
- Low-pressure daily planning

### 4. Monetization Candidates

Possible monetization ideas:

- Premium AI plan compression
- Advanced history and statistics
- Custom mascot skins
- Ad-supported RP rewards
- Student-focused premium mode

---

## Learning Goals

This project is also a learning project.

Current learning goals:

- Terminal basics
- Git and GitHub workflow
- Flutter project structure
- Dart basics
- StatefulWidget and setState
- SharedPreferences
- Asset management
- Debugging with search commands
- Web deployment with GitHub Pages
- README and roadmap documentation
- Product thinking
- MVP improvement process

---

## Personal Development Note

The goal is not just to build an app with AI assistance.

The real goal is to learn how to:

- Define a problem
- Build an MVP
- Test it
- Find bugs
- Improve the product
- Document the process
- Deploy a working demo
- Explain the project in interviews

AI tools can help with implementation, but the project owner must understand the structure, test the result, make decisions, and explain the work.

