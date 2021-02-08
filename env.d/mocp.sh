if \
  command -v mocp 1>/dev/null 2>&1 && \
  [ -L ~/.moc/config ] && \
  grep -iq '#\sautostart' ~/.moc/config; then
  mocp -i || mocp
fi
