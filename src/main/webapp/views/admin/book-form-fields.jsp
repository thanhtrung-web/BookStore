<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    .form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px}
    .form-grid label{display:grid;gap:6px;color:#334155;font-weight:700}
    .form-grid input,.form-grid select,.form-grid textarea{padding:10px;border:1px solid #cbd5e1;border-radius:7px;font:inherit}
    .form-grid .wide{grid-column:1/-1}
    @media(max-width:650px){.form-grid{grid-template-columns:1fr}.form-grid .wide{grid-column:auto}}
</style>
<div class="form-grid">
    <label>Book Title *<input required maxlength="255" name="title" value="<c:out value='${book.title}'/>"/></label>
    <label>ISBN *<input required maxlength="20" name="isbn" value="<c:out value='${book.isbn}'/>"/></label>
    <label>Publisher *<select required name="publisherId"><option value="">Select a publisher</option><c:forEach items="${publishers}" var="publisher"><option value="${publisher.id}" ${book.publisherId == publisher.id ? 'selected' : ''}><c:out value="${publisher.name}"/></option></c:forEach></select></label>
    <label>Categories<select name="categoryIds" multiple size="4"><c:forEach items="${categories}" var="category"><option value="${category.id}" ${book.categoryIds.contains(category.id) ? 'selected' : ''}><c:out value="${category.name}"/></option></c:forEach></select></label>
    <label>Authors<select name="authorIds" multiple size="4"><c:forEach items="${authors}" var="author"><option value="${author.id}" ${book.authorIds.contains(author.id) ? 'selected' : ''}><c:out value="${author.name}"/></option></c:forEach></select></label>
    <label>Original Price *<input required type="number" min="0.01" step="0.01" name="price" value="${book.price}"/><small>Sale price is calculated from the discount.</small></label>
    <label>Publication Year<input type="number" min="0" name="publicationYear" value="${book.publicationYear}"/></label>
    <label>Edition<input type="number" min="1" name="edition" value="${book.edition}"/></label>
    <label>Discount (%)<input type="number" min="0" max="100" name="discountPercent" value="${empty book.discountPercent ? 0 : book.discountPercent}"/></label>
    <label>Page Count<input type="number" min="1" name="pageCount" value="${book.pageCount}"/></label>
    <c:if test="${empty book.id}"><label>Initial Stock<input type="number" min="0" name="initialStock" value="0"/></label></c:if>
    <label>Weight (g)<input type="number" min="1" name="weightGrams" value="${empty book.weightGrams ? 300 : book.weightGrams}"/></label>
    <label>Dimensions<input name="dimensions" value="<c:out value='${book.dimensions}'/>"/></label>
    <label>Cover Type<input name="coverType" value="<c:out value='${book.coverType}'/>"/></label>
    <label>Language<input name="language" value="<c:out value='${empty book.language ? "Vietnamese" : book.language}'/>"/></label>
    <label>Status<select name="status"><option value="ACTIVE" ${empty book.status || book.status == 'ACTIVE' ? 'selected' : ''}>Active</option><option value="INACTIVE" ${book.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option></select></label>
    <label>Cover Image URL<input type="url" maxlength="500" name="imageUrl" value="<c:out value='${book.imageUrl}'/>"/></label>
    <label>Upload Cover Image (JPG/PNG, max 5 MB)<input type="file" name="coverImage" accept=".jpg,.jpeg,.png,image/jpeg,image/png"/></label>
    <label class="wide">Description<textarea name="description" rows="5"><c:out value="${book.description}"/></textarea></label>
</div>
<p style="color:#64748b">* Required</p>
