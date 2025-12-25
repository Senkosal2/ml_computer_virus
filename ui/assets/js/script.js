$(document).ready(() => {
  // --- your existing refs ---
  let form = $('#upload');
  let pe_file = $('#pe_file');
  let btnUpload = $('#btnUpload');

  // --- Bootstrap modal instance (make sure #resultModal exists in HTML) ---
  const resultModalEl = document.getElementById('resultModal');
  const resultModal = resultModalEl ? new bootstrap.Modal(resultModalEl) : null;

  // --- loader inside your existing button ---
  // NOTE: you previously said "don't touch class .loader".
  // This code does NOT change the .loader CSS, it only toggles visibility.
  const loader = btnUpload.find('.loader');

  // Helpers
  function setLoading(isLoading) {
    btnUpload.prop('disabled', isLoading);
    if (isLoading) loader.show();
    else loader.hide();
  }

  // ✅ Updated to match your API response:
  // filename, prediction, "Malware probability", feature
  function showResultInModalFromApi(response, fallbackFilename) {
    const apiFilename = response?.filename ?? "";
    const filename = apiFilename || fallbackFilename || "";

    const predictionRaw = response?.prediction ?? "UNKNOWN";
    const prediction = String(predictionRaw).toUpperCase();

    // IMPORTANT: key has a space -> bracket access
    const malwareProb = response?.["Malware probability"];

    // --- Update your prediction-result block (you wanted to keep this layout) ---
    // Requires: <span id="predictionText">...</span> and <img id="icon" ...>
    if ($("#predictionText").length) $("#predictionText").text(prediction);

    if ($("#icon").length) {
      if (prediction.includes("MAL")) {
        $("#icon").attr("src", "./assets/image/bio.svg");
      } else {
        $("#icon").attr("src", "./assets/image/check.svg");
      }
    }

    // --- Optional extra fields if you have them in modal ---
    if ($("#fileName").length) $("#fileName").text(filename ? `File: ${filename}` : "");
    if ($("#predictionTime").length) $("#predictionTime").text(new Date().toLocaleString());

    // If you added an element for probability, e.g. <span id="malProb"></span>
    if ($("#malProb").length && malwareProb !== undefined && malwareProb !== null) {
      $("#malProb").text((Number(malwareProb) * 100).toFixed(2) + "%");
    }

    // If you still have #resultIcon from older version, update it too (optional)
    if ($("#resultIcon").length) {
      if (prediction.includes("MAL")) $("#resultIcon").attr("src", "./assets/image/bio.svg");
      else $("#resultIcon").attr("src", "./assets/image/check.svg");
    }

    // Open modal only when we have a result
    if (resultModal) resultModal.show();
  }

  // Hide loader on first load (in case it's visible by default)
  setLoading(false);

  // 1) Click upload button -> open file chooser
  btnUpload.on('click', function (e) {
    e.preventDefault();
    pe_file.trigger('click');
  });

  // 2) When file selected -> auto-submit
  pe_file.on('change', function () {
    if (pe_file[0].files && pe_file[0].files.length > 0) {
      form.trigger('submit');
    }
  });

  // 3) Submit -> AJAX -> when success, open modal
  form.on('submit', function (e) {
    e.preventDefault();

    const file = pe_file[0].files && pe_file[0].files[0];
    if (!file) return;

    let formData = new FormData(this);

    setLoading(true);

    $.ajax({
      url: "http://localhost:8000/computer-virus/api/predict/",
      method: "POST",
      data: formData,
      processData: false,
      contentType: false,

      success: function (response) {
        console.log("API response:", response);

        // Optional: update any inline result (if exists)
        if ($('#result').length) $('#result').text("Upload success!");

        // ✅ Use your API fields exactly
        showResultInModalFromApi(response, file.name);
      },

      error: function (err) {
        if ($('#result').length) $('#result').text("Upload failed.");
        console.error("API error:", err);

        // Show a simple error in your existing prediction area if present
        if ($("#predictionText").length) $("#predictionText").text("FAILED");
        if ($("#fileName").length) $("#fileName").text("");
        if ($("#predictionTime").length) $("#predictionTime").text("");

        if (resultModal) resultModal.show();
      },

      complete: function () {
        setLoading(false);
        // Reset file input so selecting the same file again triggers change
        pe_file.val('');
      }
    });
  });
});
