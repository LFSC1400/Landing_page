const sections = document.querySelectorAll('section[id]');
const navItems = document.querySelectorAll('.nav-item');

window.addEventListener('scroll', () => {
  let current = '';
  sections.forEach(sec => {
    if (window.scrollY >= sec.offsetTop - 200) {
      current = sec.id;
    }
  });
  navItems.forEach(item => {
    item.classList.toggle('active', item.getAttribute('href') === '#' + current);
  });
});

navItems.forEach(item => {
  item.addEventListener('click', () => {
    navItems.forEach(b => b.classList.remove('active'));
    item.classList.add('active');
  });
});

// PRODUTOS
const slides = document.querySelectorAll('.slide');
const btnPrev = document.querySelector('.slide-btn.prev');
const btnNext = document.querySelector('.slide-btn.next');
let slideAtual = 0;

function mostrarSlide(index) {
  slides.forEach(s => s.classList.remove('active'));
  slides[index].classList.add('active');
  btnPrev.disabled = index === 0;
  btnNext.disabled = index === slides.length - 1;
}

btnPrev.addEventListener('click', () => {
  if (slideAtual > 0) mostrarSlide(--slideAtual);
});

btnNext.addEventListener('click', () => {
  if (slideAtual < slides.length - 1) mostrarSlide(++slideAtual);
});

mostrarSlide(0);

// CREDITOS
const track = document.getElementById('carrosselTrack');
const cards = Array.from(document.querySelectorAll('.membro-card'));

cards.forEach(card => {
  const clone = card.cloneNode(true);
  clone.setAttribute('aria-hidden', 'true');
  track.appendChild(clone);
});

const larguraCard = () => cards[0].offsetWidth + 20;
const totalOriginal = cards.length;
let posicao = 0;

function animar() {
  posicao += 0.5;

  if (posicao >= larguraCard() * totalOriginal) {
    posicao = 0;
  }

  track.style.transform = `translateX(-${posicao}px)`;
  requestAnimationFrame(animar);
}

requestAnimationFrame(animar);