# 00: Planning before building

## What we did

Before writing any code, Claude ran in **plan mode**: read-only, with one writable plan file. In that mode it:

1. Checked the machine. It found Command Line Tools without Xcode, no Rust, and a GitHub CLI logged into a different account than git uses.
2. Searched the web to verify Spotify's current API rules. This changed the architecture: mood must be computed from audio, and Spotify became optional.
3. Asked you three decisions with **AskUserQuestion**: stack, phone playback, and learning style. When you wanted to clarify, it answered your cross-platform question first, then re-asked.
4. Spawned a **Plan subagent** in the background to stress-test the technical design independently, while it drafted the environment sections itself.
5. Checked one of the subagent's claims, that the Command Line Tools already contain the process-tap headers, before trusting it.

## Concepts

- **Plan mode** separates thinking from doing. You approve a written plan before anything on disk changes.
- **Subagents** get a fresh context window. You pay for a full briefing, and you get back only a summary. That is good for independent research or second opinions, and wasteful for a lookup you could do in one command.
- **Verify agent output.** A subagent's mistakes come back sounding exactly as confident as its correct findings.
- **Constraint discovery** is systems design step one. The Spotify limits were outside our control and decided more of the architecture than any preference did.

## Your notes

_Write here: what surprised you, what you would ask differently next time._
