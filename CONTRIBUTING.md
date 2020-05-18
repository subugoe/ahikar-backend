# How To Contribute

The following is a set of guidelines for contributing to the Ahiqar project's back end.
Feel free to propose changes whenever the workflow could be improved!


## Issue Tracker

Issues are created and assigned by the project's Product Owner during a sprint planning in the [issue tracker](https://gitlab.gwdg.de/subugoe/ahiqar/backend/-/issues).
As soon as you start working on a assigned issue, switch its label to `Doing`.
This will cause the issue to be moved into the right list of the repository's [board](https://gitlab.gwdg.de/subugoe/ahiqar/backend/-/boards).


## Internal Workflow

### Reporting Bugs or Change Requests

Bugs and change requests are managed by the project's Product Owner.
Please report any problems that aren't related to to bugfix/feature you're working on right now to her/him.
She/he will create an issue in the correct repository and ask for assignees in the course of the next sprint planning.


### Git Flow

For developing in Ahiqar we use `git flow` as a branching and development model.
This means that all development will be reviewed before they will be merged to the `develop` branch.
Please confer [Atlassian's git flow tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) for more information on how git flow works.

Every branch should be to dedicated to an issue, i.e. there shouldn't be any branches without a corresponding ticket.
Each branch should start with the dedicated issue number and a short description on what the ticket is about, e.g. `feature/#1-contributing`.
All issues will be arranged in [milestones](https://gitlab.gwdg.de/groups/subugoe/ahiqar/-/milestones).
Milestones are always group-wide, so we combine tickets from all repositories associated with Ahiqar to a single milestone.
The milestone number is increased with each sprint.

### Merge Requests (MR)

Merge requests should be peer reviewed before merging them into `develop`.
Please choose a person you see fit as assignee.
Each MR should be associated with the current sprint's [milestone](https://gitlab.gwdg.de/groups/subugoe/ahiqar/-/milestones).
Always squash commit your MR and make sure the source branch (hotfix/bugfix/feature) is deleted after the MR has been accepted.
In case an assignee wants something to be changed in the MR, the MR is reassigned to the original reviser of the issue.
After implementing (or declining) the desired suggestions, the MR is reassigned to the original assignee.
If a merge conflict occurs the person who has proposed the MR is responsible for solving all conflicts.
