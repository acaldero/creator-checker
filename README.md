<h1 align="center">CREATOR Checker</h1>

<p align="center">
  <strong>Automated grading and testing tool for student code submissions using Docker.</strong>
</p>

<p align="center">
  <a href="https://hub.docker.com/repository/docker/creatorsim/creator-checker">
    <img src="https://img.shields.io/badge/Docker-Ready-blue?logo=docker" alt="Docker">
  </a>
  <img src="https://img.shields.io/docker/pulls/creatorsim/creator-checker?style=flat&logo=docker&logoColor=white" alt="Docker Pulls"/>
  <img src="https://img.shields.io/docker/image-size/creatorsim/creator-checker?sort=date&style=flat&logo=docker&logoColor=white" alt="Docker Image Size"/>
</p>

---

## 1. Main Files and Directories

* 📄 `creator_checker.sh` – Main execution script.
* 🗂️ `docker/` – Contains Docker-related configuration files.
* 🗂️ `submissions/` – Student submissions organized by group.
* 🗂️ `tests/` – Test programs and reference solutions.
* 🗂️ `scripts/` – Correction scripts:
  * 📄 `s10_unzip.sh` – Unzips group submissions.
  * 📄 `s20_checker.sh` – Executes tests for a specified group.
* 🗂️ `results/` – Evaluation results and grades.

---

## 2. Steps to Check All Submissions from a Group

1. **Clone the repository:**
   ```bash
   git clone https://github.com/creatorsim/creator-checker.git
   cd creator-checker
   ```

2. **Prepare the environment:**
   Build or pull the required Docker container.

   * *Option A: Build the container locally*
     ```bash
     ./creator_checker.sh build
     ```
   * *Option B: Pull the container from Docker Hub*
     ```bash
     ./creator_checker.sh pull
     ```

3. **Start the container:**
   ```bash
   ./creator_checker.sh start
   ```

4. **Prepare test files:**
   Replace the example test files in the `tests/` directory with your target correction test suite. <br>
   See [`CREATOR Wiki - Validating program execution`](https://creatorsim.github.io/creator-wiki/teaching-resources/validator.html).

5. **Add student submissions:**
   Place the student submission files (`*.zip`) inside the `submissions/` directory.

6. **Unzip group submissions:**
   ```bash
   ./scripts/s10_unzip.sh <group_name>
   ```

7. **Run the evaluation script:**
   Executes tests for the target group and generates a CSV file with results in the `results/` directory.
   ```bash
   ./scripts/s20_checker.sh <group_name>
   ```

8. **Stop the container:**
   ```bash
   ./creator_checker.sh stop
   ```

9. **See results at:**
   ```bash
   firefox ./results/<group_name>/index_<group_name>.html
   ```

