# DayRescue Test Cases

This document records manual test cases for DayRescue.

The goal is to verify that DayRescue creates realistic rescue plans depending on the user's remaining tasks, condition, deadline, loss level, and available time.

---

## Test Goal

DayRescue should help users reduce a broken daily plan into a smaller, executable rescue plan.

The app should not simply list tasks.  
It should decide:

- What must be saved today
- What can be kept lightly
- What should be reduced
- What can be strategically excluded
- Why each decision was made

---

## Test Case 1: Normal Study Routine

### Input

Remaining tasks:

```text
공부, 운동, 영어

