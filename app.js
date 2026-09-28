/**
 * IDIOM DETECTIVE — APP LOGIC ENGINE
 * Handles data fetching, real-time search, category filtering,
 * quiz game mechanics, favorite state persistence, and modal views.
 */

class IdiomDetectiveApp {
  constructor() {
    this.idioms = [];
    this.favorites = new Set(JSON.parse(localStorage.getItem('idiom_favorites') || '[]'));
    this.history = JSON.parse(localStorage.getItem('idiom_history') || '[]');
    
    // Quiz State
    this.quizState = {
      active: false,
      difficulty: 'ALL',
      questions: [],
      currentIndex: 0,
      score: 0,
      highScore: parseInt(localStorage.getItem('idiom_high_score') || '0', 10),
      streak: parseInt(localStorage.getItem('idiom_streak') || '0', 10),
      currentStreak: 0
    };

    this.init();
  }

  async init() {
    this.bindEvents();
    this.loadTheme();
    await this.fetchIdioms();
    this.renderHome();
    this.renderExplore();
    this.updateFavCount();
    this.updateQuizStats();
  }

  // --- Data Fetching ---
  async fetchIdioms() {
    try {
      const response = await fetch('assets/data/idioms.json');
      if (!response.ok) throw new Error('Failed to load dataset');
      this.idioms = await response.json();
      console.log(`Loaded ${this.idioms.length} idioms successfully.`);
    } catch (err) {
      console.error('Error loading idioms dataset:', err);
    }
  }

  // --- Event Bindings ---
  bindEvents() {
    // Navigation Tabs
    document.querySelectorAll('[data-tab]').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const tab = e.currentTarget.dataset.tab;
        this.switchTab(tab);
      });
    });

    // Theme Toggle
    document.getElementById('theme-toggle').addEventListener('click', () => this.toggleTheme());

    // Brand Logo Home Reset
    document.getElementById('brand-logo').addEventListener('click', () => this.switchTab('home'));

    // Search Box Inputs
    const homeSearch = document.getElementById('home-search-input');
    const clearBtn = document.getElementById('clear-search-btn');

    homeSearch.addEventListener('input', (e) => {
      const query = e.target.value.trim();
      clearBtn.classList.toggle('hidden', query === '');
      this.handleSearch(query);
    });

    clearBtn.addEventListener('click', () => {
      homeSearch.value = '';
      clearBtn.classList.add('hidden');
      this.renderHome();
    });

    // Random Idiom Button
    document.getElementById('random-idiom-btn').addEventListener('click', () => this.showRandomIdiom());

    // Explore Filters
    document.getElementById('explore-category-select').addEventListener('change', () => this.renderExplore());
    document.getElementById('explore-filter-input').addEventListener('input', () => this.renderExplore());
    
    document.querySelectorAll('#difficulty-chips .chip').forEach(chip => {
      chip.addEventListener('click', (e) => {
        document.querySelectorAll('#difficulty-chips .chip').forEach(c => c.classList.remove('active'));
        e.currentTarget.classList.add('active');
        this.renderExplore();
      });
    });

    // Subtab Switching (Saved)
    document.querySelectorAll('.subtab-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        document.querySelectorAll('.subtab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.subtab-content').forEach(c => c.classList.remove('active'));
        
        e.currentTarget.classList.add('active');
        const subtab = e.currentTarget.dataset.subtab;
        document.getElementById(`saved-${subtab}-view`).classList.add('active');
        
        if (subtab === 'favorites') this.renderFavorites();
        if (subtab === 'history') this.renderHistory();
      });
    });

    document.getElementById('clear-history-btn').addEventListener('click', () => this.clearHistory());

    // Quiz Controls
    document.querySelectorAll('.mode-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('active'));
        e.currentTarget.classList.add('active');
        this.quizState.difficulty = e.currentTarget.dataset.quizDiff;
      });
    });

    document.getElementById('start-quiz-btn').addEventListener('click', () => this.startQuiz());
    document.getElementById('next-question-btn').addEventListener('click', () => this.nextQuestion());
    document.getElementById('retry-quiz-btn').addEventListener('click', () => this.startQuiz());
    document.getElementById('exit-quiz-btn').addEventListener('click', () => {
      this.showQuizView('quiz-start-view');
      this.switchTab('home');
    });

    // Modal Dossier Controls
    document.getElementById('modal-close-btn').addEventListener('click', () => this.closeModal());
    document.getElementById('idiom-modal-overlay').addEventListener('click', (e) => {
      if (e.target.id === 'idiom-modal-overlay') this.closeModal();
    });
  }

  // --- Tab Navigation ---
  switchTab(tabId) {
    document.querySelectorAll('.nav-btn, .mobile-nav-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.tab === tabId);
    });

    document.querySelectorAll('.tab-page').forEach(page => {
      page.classList.remove('active');
    });

    const activePage = document.getElementById(`${tabId}-tab`);
    if (activePage) activePage.classList.add('active');

    if (tabId === 'saved') this.renderFavorites();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  // --- Theme Toggle ---
  toggleTheme() {
    const html = document.documentElement;
    const current = html.getAttribute('data-theme') || 'dark';
    const next = current === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('idiom_theme', next);

    const icon = document.querySelector('#theme-toggle i');
    icon.className = next === 'dark' ? 'fa-solid fa-moon' : 'fa-solid fa-sun';
  }

  loadTheme() {
    const saved = localStorage.getItem('idiom_theme') || 'dark';
    document.documentElement.setAttribute('data-theme', saved);
    const icon = document.querySelector('#theme-toggle i');
    icon.className = saved === 'dark' ? 'fa-solid fa-moon' : 'fa-solid fa-sun';
  }

  // --- Render Home ---
  renderHome() {
    if (!this.idioms.length) return;
    this.renderDailyCase();
    this.renderQuickCategories();
    this.renderIdiomsGrid(this.idioms.slice(0, 18), 'main-idioms-grid');
    document.getElementById('idioms-count-label').textContent = `${this.idioms.length} total idioms`;
  }

  renderDailyCase() {
    // Pick deterministic daily idiom based on current date
    const todayStr = new Date().toISOString().slice(0, 10);
    let hash = 0;
    for (let i = 0; i < todayStr.length; i++) hash = todayStr.charCodeAt(i) + ((hash << 5) - hash);
    const index = Math.abs(hash) % this.idioms.length;
    const idiom = this.idioms[index];

    const container = document.getElementById('daily-case-container');
    container.innerHTML = `
      <div class="daily-case-header">
        <span class="badge-pill"><i class="fa-solid fa-star"></i> CASE OF THE DAY</span>
        <div class="card-meta">
          <span class="tag category-tag">${idiom.category}</span>
          <span class="tag difficulty-tag ${idiom.difficulty}">${idiom.difficulty}</span>
        </div>
      </div>
      <h3 class="daily-title">"${idiom.idiom}"</h3>
      <p class="daily-meaning">${idiom.meaning}</p>
      <div class="daily-example">
        <i class="fa-solid fa-quote-left"></i> ${idiom.example}
      </div>
      <div style="margin-top: 1rem; display: flex; gap: 0.75rem;">
        <button class="btn primary-btn" onclick="app.openModal(${idiom.id})"><i class="fa-solid fa-magnifying-glass"></i> Inspect Dossier</button>
        <button class="fav-btn ${this.favorites.has(idiom.id) ? 'active' : ''}" onclick="app.toggleFavorite(${idiom.id}, event)">
          <i class="${this.favorites.has(idiom.id) ? 'fa-solid' : 'fa-regular'} fa-star"></i>
        </button>
      </div>
    `;
  }

  renderQuickCategories() {
    const categoriesMap = {};
    this.idioms.forEach(i => {
      categoriesMap[i.category] = (categoriesMap[i.category] || 0) + 1;
    });

    const categoryIcons = {
      "Actions & Behavior": "fa-person-running",
      "Animals & Nature": "fa-paw",
      "Body & Health": "fa-heart-pulse",
      "Business & Money": "fa-coins",
      "Emotion & Feelings": "fa-face-smile",
      "Time & Speed": "fa-stopwatch",
      "Food & Drink": "fa-utensils",
      "Crime & Mystery": "fa-user-ninja",
      "Mind & Intelligence": "fa-brain",
      "Social & Relationships": "fa-users"
    };

    const grid = document.getElementById('quick-categories-grid');
    const select = document.getElementById('explore-category-select');
    grid.innerHTML = '';
    select.innerHTML = '<option value="ALL">All Categories</option>';

    Object.entries(categoriesMap).forEach(([cat, count]) => {
      const icon = categoryIcons[cat] || 'fa-folder';
      grid.innerHTML += `
        <div class="category-card" onclick="app.filterByCategory('${cat}')">
          <div class="category-icon" style="background: rgba(56, 189, 248, 0.15); color: var(--accent-cyan);">
            <i class="fa-solid ${icon}"></i>
          </div>
          <div class="category-info">
            <h4>${cat}</h4>
            <span>${count} idioms</span>
          </div>
        </div>
      `;

      select.innerHTML += `<option value="${cat}">${cat} (${count})</option>`;
    });

    document.getElementById('view-all-categories-link').onclick = (e) => {
      e.preventDefault();
      this.switchTab('explore');
    };
  }

  filterByCategory(cat) {
    this.switchTab('explore');
    document.getElementById('explore-category-select').value = cat;
    this.renderExplore();
  }

  // --- Real-time Search ---
  handleSearch(query) {
    if (!query) {
      document.getElementById('idioms-list-title').innerHTML = '<i class="fa-solid fa-list-check highlight-icon"></i> Popular Evidence';
      this.renderHome();
      return;
    }

    const q = query.toLowerCase();
    const results = this.idioms.filter(i => 
      i.idiom.toLowerCase().includes(q) ||
      i.meaning.toLowerCase().includes(q) ||
      i.explanation.toLowerCase().includes(q)
    );

    document.getElementById('idioms-list-title').innerHTML = `<i class="fa-solid fa-magnifying-glass highlight-icon"></i> Search Results for "${query}"`;
    document.getElementById('idioms-count-label').textContent = `${results.length} found`;
    this.renderIdiomsGrid(results.slice(0, 36), 'main-idioms-grid');
  }

  // --- Explore Page Render ---
  renderExplore() {
    const category = document.getElementById('explore-category-select').value;
    const activeChip = document.querySelector('#difficulty-chips .chip.active');
    const difficulty = activeChip ? activeChip.dataset.difficulty : 'ALL';
    const filterQuery = document.getElementById('explore-filter-input').value.toLowerCase().trim();

    let list = this.idioms;

    if (category !== 'ALL') list = list.filter(i => i.category === category);
    if (difficulty !== 'ALL') list = list.filter(i => i.difficulty === difficulty);
    if (filterQuery) {
      list = list.filter(i => 
        i.idiom.toLowerCase().includes(filterQuery) || 
        i.meaning.toLowerCase().includes(filterQuery)
      );
    }

    this.renderIdiomsGrid(list, 'explore-idioms-grid');
  }

  // --- Render Cards Grid Helper ---
  renderIdiomsGrid(items, targetGridId) {
    const grid = document.getElementById(targetGridId);
    if (!grid) return;

    if (!items.length) {
      grid.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 3rem 1rem;" class="glass-card">
          <i class="fa-solid fa-folder-open" style="font-size: 2.5rem; color: var(--text-muted); margin-bottom: 1rem;"></i>
          <h3>No evidence found</h3>
          <p style="color: var(--text-secondary);">Try adjusting your search or category filters.</p>
        </div>
      `;
      return;
    }

    grid.innerHTML = items.map(item => {
      const isFav = this.favorites.has(item.id);
      return `
        <div class="idiom-card" onclick="app.openModal(${item.id})">
          <div>
            <div class="card-top">
              <h4 class="card-title">${item.idiom}</h4>
              <button class="fav-btn ${isFav ? 'active' : ''}" onclick="event.stopPropagation(); app.toggleFavorite(${item.id}, event)">
                <i class="${isFav ? 'fa-solid' : 'fa-regular'} fa-star"></i>
              </button>
            </div>
            <p class="card-meaning">${item.meaning}</p>
          </div>
          <div class="card-meta">
            <span class="tag category-tag">${item.category}</span>
            <span class="tag difficulty-tag ${item.difficulty}">${item.difficulty}</span>
          </div>
        </div>
      `;
    }).join('');
  }

  // --- Favorite Operations ---
  toggleFavorite(id, event) {
    if (event) event.stopPropagation();
    if (this.favorites.has(id)) {
      this.favorites.delete(id);
    } else {
      this.favorites.add(id);
    }

    localStorage.setItem('idiom_favorites', JSON.stringify(Array.from(this.favorites)));
    this.updateFavCount();

    // Refresh UI icons
    document.querySelectorAll(`.idiom-card[onclick*="${id}"] .fav-btn, button[onclick*="${id}"]`).forEach(btn => {
      const isFav = this.favorites.has(id);
      btn.classList.toggle('active', isFav);
      const icon = btn.querySelector('i');
      if (icon) icon.className = isFav ? 'fa-solid fa-star' : 'fa-regular fa-star';
    });

    const activeTab = document.querySelector('.tab-page.active').id;
    if (activeTab === 'saved-tab') this.renderFavorites();
  }

  updateFavCount() {
    const count = this.favorites.size;
    document.getElementById('fav-count-badge').textContent = count;
    document.getElementById('saved-fav-count').textContent = count;
  }

  renderFavorites() {
    const favItems = this.idioms.filter(i => this.favorites.has(i.id));
    this.renderIdiomsGrid(favItems, 'saved-favorites-grid');
  }

  // --- History Operations ---
  addToHistory(id) {
    this.history = this.history.filter(hId => hId !== id);
    this.history.unshift(id);
    if (this.history.length > 50) this.history.pop();
    localStorage.setItem('idiom_history', JSON.stringify(this.history));
  }

  renderHistory() {
    const historyItems = this.history
      .map(id => this.idioms.find(i => i.id === id))
      .filter(Boolean);
    this.renderIdiomsGrid(historyItems, 'saved-history-grid');
  }

  clearHistory() {
    this.history = [];
    localStorage.removeItem('idiom_history');
    this.renderHistory();
  }

  // --- Modal Dossier ---
  openModal(id) {
    const item = this.idioms.find(i => i.id === id);
    if (!item) return;

    this.addToHistory(id);

    document.getElementById('modal-idiom-title').textContent = item.idiom;
    document.getElementById('modal-category').textContent = item.category;
    document.getElementById('modal-difficulty').textContent = item.difficulty;
    document.getElementById('modal-difficulty').className = `tag difficulty-tag ${item.difficulty}`;
    document.getElementById('modal-usage').textContent = item.usage;

    document.getElementById('modal-meaning').textContent = item.meaning;
    document.getElementById('modal-explanation').textContent = item.explanation;
    document.getElementById('modal-example').textContent = `"${item.example}"`;

    const originContainer = document.getElementById('modal-origin-container');
    if (item.origin) {
      originContainer.style.display = 'block';
      document.getElementById('modal-origin').textContent = item.origin;
    } else {
      originContainer.style.display = 'none';
    }

    const relatedContainer = document.getElementById('modal-related-container');
    const relatedChips = document.getElementById('modal-related-chips');
    if (item.related && item.related.length) {
      relatedContainer.style.display = 'block';
      relatedChips.innerHTML = item.related.map(rel => `
        <span class="badge-pill" style="cursor: pointer;" onclick="app.searchRelated('${rel}')">${rel}</span>
      `).join('');
    } else {
      relatedContainer.style.display = 'none';
    }

    const favBtn = document.getElementById('modal-fav-btn');
    const isFav = this.favorites.has(item.id);
    favBtn.className = `fav-action-btn ${isFav ? 'active' : ''}`;
    favBtn.onclick = () => this.toggleFavorite(item.id);

    document.getElementById('idiom-modal-overlay').classList.remove('hidden');
  }

  closeModal() {
    document.getElementById('idiom-modal-overlay').classList.add('hidden');
  }

  searchRelated(term) {
    this.closeModal();
    this.switchTab('home');
    const homeSearch = document.getElementById('home-search-input');
    homeSearch.value = term;
    document.getElementById('clear-search-btn').classList.remove('hidden');
    this.handleSearch(term);
  }

  showRandomIdiom() {
    if (!this.idioms.length) return;
    const randomItem = this.idioms[Math.floor(Math.random() * this.idioms.length)];
    this.openModal(randomItem.id);
  }

  // --- Detective Quiz Game Engine ---
  updateQuizStats() {
    document.getElementById('quiz-high-score').textContent = this.quizState.highScore;
    document.getElementById('quiz-streak').textContent = `${this.quizState.streak} 🔥`;
    document.getElementById('quiz-rank-label').textContent = this.getRankName(this.quizState.highScore);
  }

  getRankName(score) {
    if (score >= 2000) return 'Master Detective 🕵️‍♂️';
    if (score >= 1200) return 'Chief Superintendent 🚔';
    if (score >= 600) return 'Senior Inspector 🔎';
    if (score >= 200) return 'Junior Detective 📜';
    return 'Rookie Inspector 🔰';
  }

  startQuiz() {
    let pool = this.idioms;
    if (this.quizState.difficulty !== 'ALL') {
      pool = pool.filter(i => i.difficulty === this.quizState.difficulty);
    }

    const shuffled = [...pool].sort(() => 0.5 - Math.random());
    this.quizState.questions = shuffled.slice(0, 10);
    this.quizState.currentIndex = 0;
    this.quizState.score = 0;
    this.quizState.active = true;

    this.showQuizView('quiz-game-view');
    this.renderQuizQuestion();
  }

  showQuizView(viewId) {
    document.querySelectorAll('.quiz-subview').forEach(v => v.classList.remove('active'));
    document.getElementById(viewId).classList.add('active');
  }

  renderQuizQuestion() {
    const q = this.quizState.questions[this.quizState.currentIndex];
    document.getElementById('current-q-num').textContent = this.quizState.currentIndex + 1;
    document.getElementById('current-score').textContent = this.quizState.score;
    document.getElementById('quiz-progress-bar').style.width = `${((this.quizState.currentIndex + 1) / 10) * 100}%`;
    document.getElementById('quiz-question-text').textContent = `"${q.idiom}"`;
    document.getElementById('quiz-feedback-box').classList.add('hidden');

    // Pick 3 distractors
    const distractors = this.idioms
      .filter(i => i.id !== q.id)
      .sort(() => 0.5 - Math.random())
      .slice(0, 3)
      .map(i => i.meaning);

    const options = [...distractors, q.meaning].sort(() => 0.5 - Math.random());

    const container = document.getElementById('quiz-options-container');
    container.innerHTML = options.map(opt => `
      <button class="quiz-opt-btn" onclick="app.handleQuizAnswer('${opt.replace(/'/g, "\\'")}', '${q.meaning.replace(/'/g, "\\'")}')">
        ${opt}
      </button>
    `).join('');
  }

  handleQuizAnswer(selected, correct) {
    const buttons = document.querySelectorAll('.quiz-opt-btn');
    buttons.forEach(btn => {
      btn.disabled = true;
      if (btn.textContent.trim() === correct) btn.classList.add('correct');
      if (btn.textContent.trim() === selected && selected !== correct) btn.classList.add('incorrect');
    });

    const isCorrect = selected === correct;
    const feedbackTitle = document.getElementById('feedback-result-title');
    const feedbackBox = document.getElementById('quiz-feedback-box');

    if (isCorrect) {
      this.quizState.score += 100;
      this.quizState.currentStreak += 1;
      feedbackTitle.innerHTML = '<span style="color: var(--accent-emerald); font-weight: 800;"><i class="fa-solid fa-circle-check"></i> Case Solved! (+100 pts)</span>';
    } else {
      this.quizState.currentStreak = 0;
      feedbackTitle.innerHTML = '<span style="color: var(--accent-rose); font-weight: 800;"><i class="fa-solid fa-circle-xmark"></i> Incorrect Evidence</span>';
    }

    document.getElementById('current-score').textContent = this.quizState.score;
    document.getElementById('feedback-explanation-text').textContent = this.quizState.questions[this.quizState.currentIndex].explanation;
    feedbackBox.classList.remove('hidden');
  }

  nextQuestion() {
    this.quizState.currentIndex += 1;
    if (this.quizState.currentIndex < 10) {
      this.renderQuizQuestion();
    } else {
      this.finishQuiz();
    }
  }

  finishQuiz() {
    const score = this.quizState.score;
    if (score > this.quizState.highScore) {
      this.quizState.highScore = score;
      localStorage.setItem('idiom_high_score', score);
    }

    if (this.quizState.currentStreak > this.quizState.streak) {
      this.quizState.streak = this.quizState.currentStreak;
      localStorage.setItem('idiom_streak', this.quizState.streak);
    }

    this.updateQuizStats();

    document.getElementById('result-score-num').textContent = score;
    document.getElementById('result-subtitle').textContent = `You accurately solved ${score / 100} out of 10 evidence cases!`;
    document.getElementById('result-rank-name').textContent = this.getRankName(score);

    this.showQuizView('quiz-result-view');
  }
}

// Global App Instance
const app = new IdiomDetectiveApp();
