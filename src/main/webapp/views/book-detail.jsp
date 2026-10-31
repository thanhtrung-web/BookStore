<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/views/common/header.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Details - BookStore</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f8fafc;
            color: #1e293b;
            margin: 0;
            padding: 30px;
        }

        .container {
            max-width: 1000px;
            margin: auto;
        }

        .book-detail {
            display: flex;
            flex-wrap: wrap;
            gap: 30px;
            background: white;
            padding: 28px;
            border-radius: 14px;
        }

        .book-image {
            width: 260px;
            max-width: 100%;
            height: 350px;
            object-fit: contain;
            background: #f1f5f9;
            border-radius: 10px;
        }

        .book-info {
            flex: 1;
            min-width: 0;
        }

        .price {
            color: #2563eb;
            font-size: 24px;
            font-weight: bold;
        }

        .description {
            line-height: 1.7;
            white-space: pre-line;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #2563eb;
            text-decoration: none;
        }

        .field {
            margin: 12px 0;
        }

        .purchase-section {
            margin-top: 30px;
            padding-top: 22px;
            border-top: 1px solid #e2e8f0;
        }

        .quantity-control {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .quantity-control label {
            font-size: 16px;
            font-weight: 600;
        }

        .quantity-box {
            display: inline-flex;
            align-items: center;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            overflow: hidden;
            background: white;
        }

        .quantity-btn {
            width: 42px;
            height: 44px;
            border: none;
            background: #f8fafc;
            font-size: 22px;
            font-weight: bold;
            cursor: pointer;
        }

        .quantity-btn:hover {
            background: #dbeafe;
            color: #2563eb;
        }

        .quantity-input {
            width: 55px;
            height: 44px;
            border: none;
            text-align: center;
            font-size: 17px;
            font-weight: 600;
            outline: none;
            appearance: textfield;
            -moz-appearance: textfield;
        }

        .quantity-input::-webkit-inner-spin-button,
        .quantity-input::-webkit-outer-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }

        .book-actions {
            display: flex;
            gap: 14px;
            width: 100%;
        }

        .btn-add-cart,
        .btn-buy-now {
            flex: 1 1 0;
            min-width: 0;
            min-height: 56px;
            padding: 10px 12px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-add-cart {
            background: white;
            color: #c92127;
            border: 2px solid #c92127;
        }

        .btn-add-cart:hover {
            background: #fff1f2;
            box-shadow: 0 4px 12px rgba(201, 33, 39, 0.12);
        }

        .btn-buy-now {
            background: #c92127;
            color: white;
            border: 2px solid #c92127;
        }

        .btn-buy-now:hover:not(:disabled) {
            background: #ad1b20;
        }

        .btn-buy-now:disabled {
            opacity: 0.55;
            cursor: not-allowed;
        }

        /* REVIEW SECTION */
        .review-section {
            margin-top: 30px;
            padding: 28px;
            background: white;
            border-radius: 14px;
        }

        .review-section h2 {
            margin-top: 0;
            margin-bottom: 20px;
        }

        .review-summary {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 20px;
            background: #f8fafc;
            border-radius: 12px;
            margin-bottom: 24px;
        }

        .average-rating {
            color: #c92127;
            font-size: 38px;
            font-weight: bold;
        }

        .stars {
            color: #f59e0b;
            letter-spacing: 2px;
        }

        .review-form {
            padding: 20px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            margin-bottom: 25px;
        }

        .review-form label {
            display: block;
            font-weight: 600;
            margin: 14px 0 8px;
        }

        .review-form select,
        .review-form textarea {
            width: 100%;
            box-sizing: border-box;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font: inherit;
        }

        .review-form textarea {
            min-height: 110px;
            resize: vertical;
        }

        .review-submit {
            margin-top: 14px;
            padding: 12px 22px;
            border: none;
            border-radius: 8px;
            background: #c92127;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }

        .review-submit:hover {
            background: #ad1b20;
        }

        .review-message {
            padding: 12px 15px;
            margin-bottom: 18px;
            background: #eff6ff;
            color: #1d4ed8;
            border-radius: 8px;
        }

        .review-item {
            padding: 20px 0;
            border-bottom: 1px solid #e2e8f0;
        }

        .review-item:last-child {
            border-bottom: none;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 8px;
        }

        .reviewer-name {
            font-weight: bold;
        }

        .review-date {
            color: #64748b;
            font-size: 13px;
        }

        .review-comment {
            line-height: 1.7;
            white-space: pre-line;
            overflow-wrap: anywhere;
        }

        .review-actions {
            display: flex;
            gap: 12px;
            margin-top: 12px;
        }

        .review-actions a,
        .review-actions button {
            border: none;
            background: none;
            padding: 0;
            color: #2563eb;
            cursor: pointer;
            text-decoration: none;
            font: inherit;
        }

        .review-actions button {
            color: #dc2626;
        }

        .review-filter {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
        }

        .review-filter select {
            padding: 9px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
        }

        .review-filter button {
            padding: 9px 16px;
            border: none;
            border-radius: 8px;
            background: #2563eb;
            color: white;
            cursor: pointer;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 24px;
            flex-wrap: wrap;
        }

        .pagination a,
        .pagination span {
            padding: 8px 13px;
            border: 1px solid #cbd5e1;
            border-radius: 7px;
            text-decoration: none;
            color: #334155;
        }

        .pagination .active {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
        }

        .empty-review {
            color: #64748b;
            padding: 20px 0;
        }

        @media (max-width: 600px) {
            body {
                padding: 15px;
            }

            .book-detail {
                padding: 18px;
            }

            .book-info {
                min-width: 100%;
            }

            .book-actions {
                flex-direction: column;
            }

            .btn-add-cart,
            .btn-buy-now {
                width: 100%;
                flex: none;
            }

            .review-section {
                padding: 18px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <a class="back-link"
       href="${pageContext.request.contextPath}/books">
        ← Back to Book List
    </a>

    <!-- BOOK DETAILS -->
    <div class="book-detail">

        <div>
            <c:choose>
                <c:when test="${not empty book.imageUrl}">
                    <img class="book-image"
     src="${book.imageUrl}"
     alt="Book Cover">
                </c:when>

                <c:otherwise>
                    <div class="book-image"
                         style="display:flex;align-items:center;justify-content:center;">
                        No Cover Image
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="book-info">

            <h1><c:out value="${book.title}" /></h1>

            <p class="price">
                <fmt:formatNumber value="${book.price}" pattern="#,##0.##" /> VND
            </p>

            <div class="field">
                <strong>ISBN:</strong>
                <c:out value="${book.isbn}" />
            </div>

            <div class="field">
                <strong>Publisher:</strong>
                <c:out value="${book.publisherName}" />
            </div>

            <div class="field">
                <strong>Publication Year:</strong>
                <c:out value="${book.publicationYear}" />
            </div>

            <div class="field">
                <strong>Edition:</strong>
                <c:out value="${book.edition}" />
            </div>

            <div class="field">
                <strong>Pages:</strong>
                <c:out value="${book.pageCount}" />
            </div>

            <div class="field">
                <strong>Cover Type:</strong>
                <c:out value="${book.coverType}" />
            </div>

            <div class="field">
                <strong>Language:</strong>
                <c:out value="${book.language}" />
            </div>

            <div class="field">
                <strong>Discount:</strong>
                <c:out value="${book.discountPercent}" />%
            </div>

            <h3>Book Description</h3>

            <p class="description">
                <c:out value="${book.description}" />
            </p>

            <!-- PURCHASE SECTION -->
            <div class="purchase-section">

                <form id="addToCartForm"
                      action="${pageContext.request.contextPath}/cart/add"
                      method="post">

                    <input type="hidden"
                           name="csrfToken"
                           value="${sessionScope.cartCsrfToken}">

                    <input type="hidden"
                           name="bookId"
                           value="${book.id}">

                    <div class="quantity-control">
                        <label for="quantity">Quantity:</label>

                        <div class="quantity-box">
                            <button type="button"
                                    class="quantity-btn"
                                    onclick="changeQuantity(-1)">−</button>

                            <input type="number"
                                   id="quantity"
                                   name="quantity"
                                   class="quantity-input"
                                   value="1"
                                   min="1"
                                   required>

                            <button type="button"
                                    class="quantity-btn"
                                    onclick="changeQuantity(1)">+</button>
                        </div>
                    </div>

                    <div class="book-actions">
                        <button type="submit" class="btn-add-cart">
                            🛒 Add to Cart
                        </button>

                        <button type="submit"
                                name="buyNow"
                                value="true"
                                class="btn-buy-now">
                            Buy Now
                        </button>
                    </div>

                </form>
            </div>
        </div>
    </div>

    <!-- REVIEW SECTION -->
    <section class="review-section">

        <h2>Ratings & Reviews</h2>

        <c:if test="${not empty reviewMessage}">
            <div class="review-message">
                <c:out value="${reviewMessage}" />
            </div>
        </c:if>

        <!-- RATING SUMMARY -->
        <div class="review-summary">
            <div>
                <div class="average-rating">
                    <fmt:formatNumber value="${averageRating}" pattern="0.0" />
                    / 5
                </div>
                <div class="stars">★★★★★</div>
                <div>
                    <c:out value="${totalReviews}" /> reviews
                </div>
            </div>
        </div>

        <!-- REVIEW FORM -->
        <c:choose>

            <c:when test="${not empty editReview}">
                <div class="review-form">
                    <h3>Edit Your Review</h3>

                    <form action="${pageContext.request.contextPath}/reviews"
                          method="post">

                        <input type="hidden" name="bookId" value="${book.id}">
                         <input type="hidden" name="reviewCsrfToken"
           value="${sessionScope.reviewCsrfToken}">
                        <input type="hidden" name="reviewId" value="${editReview.id}">
                        <input type="hidden" name="action" value="update">

                        <label for="editRating">Rating</label>
                        <select id="editRating" name="rating" required>
                            <option value="5" ${editReview.rating == 5 ? 'selected' : ''}>5 Stars</option>
                            <option value="4" ${editReview.rating == 4 ? 'selected' : ''}>4 Stars</option>
                            <option value="3" ${editReview.rating == 3 ? 'selected' : ''}>3 Stars</option>
                            <option value="2" ${editReview.rating == 2 ? 'selected' : ''}>2 Stars</option>
                            <option value="1" ${editReview.rating == 1 ? 'selected' : ''}>1 Star</option>
                        </select>

                        <label for="editComment">Your Review</label>
                        <textarea id="editComment"
                                  name="comment"
                                  maxlength="2000"
                                  required><c:out value="${editReview.comment}" /></textarea>

                        <button type="submit" class="review-submit">
                            Save Changes
                        </button>

                        <a href="${pageContext.request.contextPath}/book-detail?id=${book.id}"
                           style="margin-left:12px;">Cancel</a>
                    </form>
                </div>
            </c:when>

            <c:when test="${isBuyer and not empty ownReview}">
                <div class="review-form">
                    <h3>Your Review</h3>
                    <p>You have already reviewed this book.</p>

                    <p>
                        <span class="stars">
                            <c:forEach begin="1" end="${ownReview.rating}">
                                ★
                            </c:forEach>
                        </span>
                    </p>

                    <p><c:out value="${ownReview.comment}" /></p>

                    <a href="${pageContext.request.contextPath}/book-detail?id=${book.id}&action=edit&reviewId=${ownReview.id}">
                        Edit Review
                    </a>

                    <form action="${pageContext.request.contextPath}/reviews"
                          method="post"
                          style="display:inline;margin-left:15px;"
                          onsubmit="return confirm('Are you sure you want to delete this review?');">

                        <input type="hidden" name="bookId" value="${book.id}">
                        <input type="hidden" name="reviewCsrfToken"
       value="${sessionScope.reviewCsrfToken}">
                        <input type="hidden" name="reviewId" value="${ownReview.id}">
                        <input type="hidden" name="action" value="delete">

                        <button type="submit"
                                style="border:none;background:none;color:#dc2626;cursor:pointer;">
                            Delete Review
                        </button>
                    </form>
                </div>
            </c:when>

            <c:when test="${isBuyer and canWriteReview}">
                <div class="review-form">
                    <h3>Write Your Review</h3>

                    <form action="${pageContext.request.contextPath}/reviews"
                          method="post">

                        <input type="hidden" name="bookId" value="${book.id}">
                        <input type="hidden" name="reviewCsrfToken"
       value="${sessionScope.reviewCsrfToken}">
                        <input type="hidden" name="action" value="create">

                        <label for="rating">Rating</label>
                        <select id="rating" name="rating" required>
                            <option value="5">5 Stars - Excellent</option>
                            <option value="4">4 Stars - Very Good</option>
                            <option value="3">3 Stars - Average</option>
                            <option value="2">2 Stars - Below Average</option>
                            <option value="1">1 Star - Poor</option>
                        </select>

                        <label for="comment">Your Review</label>
                        <textarea id="comment"
                                  name="comment"
                                  maxlength="2000"
                                  placeholder="Share your thoughts about this book..."
                                  required></textarea>

                        <button type="submit" class="review-submit">
                            Submit Review
                        </button>
                    </form>
                </div>
            </c:when>

            <c:when test="${not isBuyer}">
                <p class="empty-review">
                    Please log in with a Buyer account to review this book.
                </p>
            </c:when>

            <c:otherwise>
                <p class="empty-review">
                    You must have a delivered order containing this book before you can write a review.
                </p>
            </c:otherwise>

        </c:choose>

        <!-- FILTER AND SORT -->
        <form class="review-filter"
              action="${pageContext.request.contextPath}/book-detail"
              method="get">

            <input type="hidden" name="id" value="${book.id}">

            <label for="sort">Sort by:</label>
            <select id="sort" name="sort">
                <option value="newest" ${sort == 'newest' ? 'selected' : ''}>
                    Newest
                </option>
                <option value="highest" ${sort == 'highest' ? 'selected' : ''}>
                    Highest Rating
                </option>
                <option value="lowest" ${sort == 'lowest' ? 'selected' : ''}>
                    Lowest Rating
                </option>
            </select>

            <label for="ratingFilter">Filter by Rating:</label>
            <select id="ratingFilter" name="rating">
                <option value="" ${empty ratingFilter ? 'selected' : ''}>
                    All Ratings
                </option>
                <option value="5" ${ratingFilter == 5 ? 'selected' : ''}>5 Stars</option>
                <option value="4" ${ratingFilter == 4 ? 'selected' : ''}>4 Stars</option>
                <option value="3" ${ratingFilter == 3 ? 'selected' : ''}>3 Stars</option>
                <option value="2" ${ratingFilter == 2 ? 'selected' : ''}>2 Stars</option>
                <option value="1" ${ratingFilter == 1 ? 'selected' : ''}>1 Star</option>
            </select>

            <button type="submit">Apply</button>
        </form>

        <!-- REVIEW LIST -->
        <div class="review-list">

            <c:choose>
                <c:when test="${not empty reviews}">
                    <c:forEach var="review" items="${reviews}">
                        <article class="review-item">

                            <div class="review-header">
                                <span class="reviewer-name">
                                    <c:out value="${review.reviewerName}" />
                                </span>

                                <span class="review-date">
                                    <fmt:formatDate value="${review.createdAt}"
                                                    pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>

                            <div class="stars">
                                <c:forEach begin="1" end="${review.rating}">
                                    ★
                                </c:forEach>
                                <c:forEach begin="1" end="${5 - review.rating}">
                                    ☆
                                </c:forEach>
                            </div>

                            <p class="review-comment">
                                <c:out value="${review.comment}" />
                            </p>

                        </article>
                    </c:forEach>
                </c:when>

                <c:otherwise>
                    <p class="empty-review">
                        No reviews found.
                    </p>
                </c:otherwise>
            </c:choose>

        </div>

        <!-- PAGINATION -->
        <c:if test="${totalPages > 1}">
            <div class="pagination">

                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/book-detail?id=${book.id}&reviewPage=${currentPage - 1}&sort=${sort}&rating=${ratingFilter}">
                        Previous
                    </a>
                </c:if>

                <c:forEach begin="1" end="${totalPages}" var="pageNumber">
                    <c:choose>
                        <c:when test="${pageNumber == currentPage}">
                            <span class="active">${pageNumber}</span>
                        </c:when>

                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/book-detail?id=${book.id}&reviewPage=${pageNumber}&sort=${sort}&rating=${ratingFilter}">
                                ${pageNumber}
                            </a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/book-detail?id=${book.id}&reviewPage=${currentPage + 1}&sort=${sort}&rating=${ratingFilter}">
                        Next
                    </a>
                </c:if>

            </div>
        </c:if>

    </section>

</div>

<script>
    function changeQuantity(amount) {
        const input = document.getElementById("quantity");
        const current = parseInt(input.value, 10) || 1;
        input.value = Math.max(1, current + amount);
    }
</script>

</body>
</html>

<jsp:include page="/views/common/footer.jsp" />